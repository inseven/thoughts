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
        case introductionVersion
    }

    static let introductionVersion = 1

    @MainActor var tags: Trie {
        return library?.tags ?? Trie()
    }

    @MainActor var rootURL: URL? {
        didSet {
            rootURLChanges.send(rootURL)
            reloadLibrary()
            do {
                try keyedDefaults.set(securityScopedURL: rootURL, forKey: .rootURL)
            } catch {
                print("Failed to save bookmark data with error \(error).")
            }
        }
    }

    @MainActor var shouldSaveLocation: Bool {
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

    @MainActor var introductionVersion: Int {
        didSet {
            keyedDefaults.set(introductionVersion, forKey: .introductionVersion)
        }
    }

    @MainActor var document = Document() {
        didSet {
            documentChanges.send(document)
        }
    }

    @MainActor var useDemoData: Bool = false {
        didSet {
            useDemoDataChanges.send(useDemoData)
            new()
        }
    }

    @MainActor var didShowIntroduction: Bool {
        return introductionVersion == Self.introductionVersion
    }

    let toggleFocusPublisher = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()
    private var locationRequests: [(Result<LocationDetails, Error>) -> Void] = []
    private var library: Library?

    private let documentChanges = PassthroughSubject<Document?, Never>()
    private let rootURLChanges = PassthroughSubject<URL?, Never>()
    private let useDemoDataChanges = PassthroughSubject<Bool, Never>()

    private let keyedDefaults = KeyedDefaults<SettingsKey>()
    private let locationManager = CLLocationManager()

    @MainActor override init() {
        rootURL = try? keyedDefaults.securityScopedURL(forKey: .rootURL)
        shouldSaveLocation = keyedDefaults.bool(forKey: .shouldSaveLocation, default: false)
        introductionVersion = keyedDefaults.integer(forKey: .introductionVersion, default: 0)
        super.init()
        rootURLChanges.send(rootURL)
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        self.start()
    }

    @MainActor private func start() {

        // Watch the document for changes, debounce, and save changes to disk.
        rootURLChanges
            .prepend(rootURL)
            .compactMap { $0 }
            .combineLatest(documentChanges.compactMap { $0 },
                           useDemoDataChanges.prepend(useDemoData))
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { rootURL, document, useDemoData in

                // Don't save the document if we're using demo data.
                guard !useDemoData else {
                    return
                }

                // Write the changes to disk.
                do {
                    try document.sync(to: rootURL)
                } catch {
                    print("Failed to save file with error '\(error)'.")
                }
            }
            .store(in: &cancellables)

        reloadLibrary()

        if !didShowIntroduction {
            showIntroduction()
        }
    }

    @MainActor func showIntroduction() {
        let window = NSIntroductionWindow(applicationModel: self)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    @MainActor func new() {
        guard didShowIntroduction else {
            return
        }
        if useDemoData {
            let location = LocationDetails(latitude: 34.2133,
                                           longitude: 135.5853,
                                           name: nil,
                                           locality: "Waialua")
            var document = Document()
            document = Document()
            document.content = """
    **Thoughts** is a lightweight note taking app for macOS.

    It’s for recording _ephemeral_ notes. For when you just want to get something down and out of your head, happy in the knowledge that it’s recorded _somewhere_.

    Thoughts doesn’t offer any viewing functionality---it’s all about file-and-forget. It saves notes in **Markdown** and **Frontmatter** so it pairs perfectly with tools like [Obsidian](https://obsidian.md) and static site builders like [Jekyll](https://jekyllrb.com), [Hugo](https://gohugo.io), and [InContext](https://incontext.app).
    """
            document.tags = ["software", "apple", "mac", "markdown", "journaling"]
            document.location = location
            self.document = document
        } else {
            document = Document()
            updateUserLocation()
        }
        NSWorkspace.shared.open(.compose)
    }

    @MainActor func toggleFocus() {
        toggleFocusPublisher.send(())
    }

    @MainActor func updateUserLocation(completion: (() -> Void)? = nil) {
        requestUserLocation { result in
            switch result {
            case .success(let location):
                self.document.location = location
            case .failure(let error):
                print("Failed to fetch location with error '\(error)'.")
            }
            completion?()
        }
    }

    // Create and start a library instance, stopping any previous library if necessary.
    // This is intended to be called when the rootURL changes. If rootURL is nil, no new library will be created.
    @MainActor func reloadLibrary() {
        library?.stop()
        library = nil
        guard let rootURL else {
            return
        }
        library = Library(rootURL: rootURL)
        library?.start()
    }

    @MainActor func setRootURL() -> Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        guard openPanel.runModal() ==  NSApplication.ModalResponse.OK,
              let url = openPanel.url else {
            return false
        }
        rootURL = url
        document = Document()
        return true
    }

}

extension ApplicationModel: CLLocationManagerDelegate {

    @MainActor private func requestUserLocation(completion: @escaping (Result<LocationDetails, Error>) -> Void) {
        guard CLLocationManager.locationServicesEnabled() else {
            completion(.failure(ThoughtsError.locationServicesDisabled))
            return
        }
        guard shouldSaveLocation else {
            completion(.failure(ThoughtsError.userLocationDisabled))
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
            return LocationDetails(location: location,
                                   placemark: try await geocoder.reverseGeocodeLocation(location).first)
        } catch {
            print("Failed to geocode location with error '\(error)'.")
            return LocationDetails(location: location)
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
        print("Location manager did fail with error '\(error)'.")
        resolveRequests(.failure(error))
    }

    func locationManager(_ manager: CLLocationManager, 
                         monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        print("Location manager monitoring did fail with error '\(error)'.")
        resolveRequests(.failure(error))
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Did pause location updates.")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Did resume location updates.")
    }

}
