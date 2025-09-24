// Copyright (c) 2024-2025 Jason Morley
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

import SwiftUI

struct Update: Codable {

    let url: URL
    let version: String

}

// Guaranteed to be called on the main thread.
protocol StoreUpdateCheckerDelegate: NSObject {

    @MainActor func storeUpdateChecker(_ storeUpdateChecker: StoreUpdateChecker,
                                       didDismissAlertWithSuppressionState suppressionState: Bool)

}

class StoreUpdateChecker: @unchecked Sendable {

    weak var delegate: StoreUpdateCheckerDelegate? = nil

    init() {
    }

    func check() {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: "https://thoughts.jbmorley.co.uk/current.json")!)
                let decoder = JSONDecoder()
                let current = try decoder.decode(Update.self, from: data)

                guard Bundle.main.version != current.version else {
                    return
                }

                DispatchQueue.main.async {
                    self.present()
                }

            } catch {
                print("Failed to check for update with error '\(error)'.")
            }
        }
    }

    @MainActor func present() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Update Available"
        alert.informativeText = "Thoughts is no longer being updated on the Mac App Store. Please download the latest update from the website."
        alert.showsSuppressionButton = true
        _ = alert.addButton(withTitle: "OK")
        alert.runModal()
        let suppressionState = alert.suppressionButton?.state as? NSControl.StateValue ?? .off
        delegate?.storeUpdateChecker(self, didDismissAlertWithSuppressionState: suppressionState == .on)
    }

}
