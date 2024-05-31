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
import UniformTypeIdentifiers

import FrontmatterSwift
import Interact

class Library {

    private static func tags(for url: URL) -> [String] {
        do {
            let document = try FrontmatterDocument(contentsOf: url)
            return document.metadata["tags"] as? [String] ?? []
        } catch {
            print("Failed to load frontmatter document '\(url)' with error '\(error)'.")
            return []
        }
    }

    private let rootURL: URL

    private let scanner: DirectoryScanner
    private let workQueue = DispatchQueue(label: "Library.workQueue")

    private var files: [Details.Identifier: [String]] = [:]

    @MainActor var tags = Trie()

    init(rootURL: URL) {
        self.rootURL = rootURL
        self.scanner = DirectoryScanner(url: rootURL)
    }

    func start() {
        self.scanner.start {
            return []
        } onFileCreation: { details in
            for details in details.filter({ $0.contentType.conforms(to: .markdown) }) {
                self.files[details.identifier] = Self.tags(for: details.url)
            }
            self.updateTags()
        } onFileUpdate: { details in
            for details in details.filter({ $0.contentType.conforms(to: .markdown) }) {
                self.files[details.identifier] = Self.tags(for: details.url)
            }
            self.updateTags()
        } onFileDeletion: { identifiers in
            for identifier in identifiers {
                self.files.removeValue(forKey: identifier)
            }
            self.updateTags()
        }
    }

    private func updateTags() {
        let tags = self.files.values.reduce(into: Set<String>()) { partialResult, tags in
            partialResult.formUnion(tags)
        }
        let trie = Trie(words: tags)
        DispatchQueue.main.async {
            self.tags = trie
        }
    }

    func stop() {
        scanner.stop()
    }

}
