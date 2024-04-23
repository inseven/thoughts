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
import CoreLocation
import Foundation

import Interact

@Observable
class ApplicationModel: NSObject {

    enum SettingsKey: String {
        case rootURL
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

    var document = Document() {
        didSet {
            guard let url = rootURL else {
                return
            }
            do {
                try document.sync(to: url)
            } catch {
                print("Failed to save file with error \(error).")
            }
        }
    }

    let keyedDefaults = KeyedDefaults<SettingsKey>()
    let locationManager = CLLocationManager()
    var lastKnownLocation: Location? = nil

    override init() {
        rootURL = try? keyedDefaults.securityScopedURL(forKey: .rootURL)
        super.init()
        locationManager.delegate = self
    }

    func new() {
        dispatchPrecondition(condition: .onQueue(.main))
        document = Document()
        document.location = lastKnownLocation
    }

    func userLocation() {
        guard locationManager.authorizationStatus != .notDetermined else {
            print("Requesting location authorization...")
            locationManager.requestWhenInUseAuthorization()
            return
        }
        print("Requsting location...")
        locationManager.requestLocation()
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

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status = \(manager.authorizationStatus.name)")
        guard manager.authorizationStatus == .authorized else {
            return
        }
        print("Requsting location...")
        manager.requestLocation()
    }

    func resolveLocation(_ location: CLLocation) async -> Location {
        let geocoder = CLGeocoder()
        do {
            guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
                return Location(location)
            }
            return Location(placemark)
        } catch {
            print("Failed to geocode location with error \(error).")
            return Location(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            guard let location = locations.first else {
                return
            }
            let lastKnownLocation = await resolveLocation(location)
            print(lastKnownLocation)
            await MainActor.run {
                self.lastKnownLocation = lastKnownLocation
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location manager did fail with error \(error).")
    }

    func locationManager(_ manager: CLLocationManager, 
                         monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        print("Location manager monitoring did fail with error \(error).")
    }

}

extension CLAuthorizationStatus {

    var name: String {
        switch self {
        case .notDetermined:
            return "not determined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorized always"
        @unknown default:
            return "unknown (\(self.rawValue))"
        }
    }

}
