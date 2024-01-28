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

import Combine
import SwiftUI

class Note: ObservableObject {

    let url: URL

    @Published var content: String = ""

    private var cancellables: Set<AnyCancellable> = []

    init(url: URL) {
        self.url = url
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        $content
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { content in
                // TODO: Report the error.
                try! content.write(to: self.url, atomically: true, encoding: .utf8)
            }
            .store(in: &cancellables)

        // Load the content before starting.
        if FileManager.default.fileExists(atPath: url.path) {
            content = try! String(contentsOf: url)
        }
    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }

}
