// Copyright (c) 2024 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import AppKit
import Combine
import CoreLocation
import Foundation

import Interact

@Observable
class ApplicationModel: NSObject {

    enum SettingsKey: String {
        case rootURL
        case shouldSaveLocation
    }

    var rootURL: URL? {
        didSet {
            do {
                try keyedDefaults.set(securityScopedURL: rootURL, forKey: .rootURL)
            } catch {
                print("Failed to save bookmark data with error \(error).")
            }
        }
    }

    var shouldSaveLocation: Bool {
        didSet {
            keyedDefaults.set(shouldSaveLocation, forKey: .shouldSaveLocation)
            if shouldSaveLocation {
                updateUserLocation()
            } else {
                document.location = nil
                locationManager.stopUpdatingLocation()
            }
        }
    }

    var document = Document() {
        didSet {
            documentChanges.send(document)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var locationRequests: [(Result<LocationDetails, Error>) -> Void] = []

    private let documentChanges = PassthroughSubject<Document?, Never>()
    private let keyedDefaults = KeyedDefaults<SettingsKey>()
    private let locationManager = CLLocationManager()

    override init() {
        rootURL = try? keyedDefaults.securityScopedURL(forKey: .rootURL)
        shouldSaveLocation = keyedDefaults.bool(forKey: .shouldSaveLocation, default: false)
        super.init()
        locationManager.delegate = self
        self.start()
    }

    private func start() {
        documentChanges
            .compactMap { $0 }
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { document in
                guard let url = self.rootURL else {
                    return
                }
                do {
                    try document.sync(to: url)
                } catch {
                    print("Failed to save file with error \(error).")
                }
            }
            .store(in: &cancellables)
    }

    func new() {
        dispatchPrecondition(condition: .onQueue(.main))
        document = Document()
        updateUserLocation()
    }

    func updateUserLocation() {
        requestUserLocation { result in
            switch result {
            case .success(let location):
                self.document.location = location
            case .failure(let error):
                print("Failed to fetch location with error \(error)")
            }
        }
    }

    func setRootURL() {
        dispatchPrecondition(condition: .onQueue(.main))
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        guard openPanel.runModal() ==  NSApplication.ModalResponse.OK,
              let url = openPanel.url else {
            return
        }
        rootURL = url
        document = Document()
    }

}

extension ApplicationModel: CLLocationManagerDelegate {

    func requestUserLocation(completion: @escaping (Result<LocationDetails, Error>) -> Void) {
        // TODO: Check if enabled.
        guard shouldSaveLocation else {
            return
        }
        locationRequests.append(completion)
        guard locationManager.authorizationStatus != .notDetermined else {
            print("Requesting location authorization...")
            locationManager.requestWhenInUseAuthorization()
            return
        }
        print("Starting updating location...")
        locationManager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        dispatchPrecondition(condition: .onQueue(.main))
        print("Location authorization status = \(manager.authorizationStatus.name)")
        guard manager.authorizationStatus == .authorized else {
            return
        }
        guard locationRequests.count > 0 else {
            return
        }
        print("Starting updating location...")
        manager.startUpdatingLocation()
    }

    func resolveLocation(_ location: CLLocation) async -> LocationDetails {
        let geocoder = CLGeocoder()
        do {
            guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
                return LocationDetails(location)
            }
            return LocationDetails(placemark)
        } catch {
            print("Failed to geocode location with error \(error).")
            return LocationDetails(location)
        }
    }

    func resolveRequests(_ result: Result<LocationDetails, Error>) {
        dispatchPrecondition(condition: .onQueue(.main))
        for locationRequest in self.locationRequests {
            locationRequest(result)
        }
        locationRequests = []
        print("Stopping updating location...")
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update locations.")
        Task {
            guard let location = locations.first else {
                return
            }
            let locationDetails = await resolveLocation(location)
            await MainActor.run {
                resolveRequests(.success(locationDetails))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location manager did fail with error \(error).")
        resolveRequests(.failure(error))
    }

    func locationManager(_ manager: CLLocationManager, 
                         monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        print("Location manager monitoring did fail with error \(error).")
        resolveRequests(.failure(error))
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Did pause location updates!")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Did resume location updates!")
    }

}
