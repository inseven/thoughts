// Copyright (c) 2021-2024 Jason Morley
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

struct Items: View {

    @ObservedObject var applicationModel: ApplicationModel

    @Environment(\.openWindow) var openWindow

    var body: some View {
        Button("New Note...") {
            let formatter = ISO8601DateFormatter()
            // TODO: Format options?
            formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate]
            let date = formatter.string(from: Date())
            let url = ApplicationModel.folderURL.appendingPathComponent(date).appendingPathExtension("md")

            // Create the file if it doesn't exist.
            if !FileManager.default.fileExists(atPath: url.path) {
                let contents = "---\ndate: \(date)\ntags:\n---\n\n"
                try! contents.write(to: url, atomically: true, encoding: .utf8)
            }

            // Open the window.
            openWindow(id: "note", value: url)
        }
    }

}
