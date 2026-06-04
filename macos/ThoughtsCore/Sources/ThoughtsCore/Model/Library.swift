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

import AppKit
import Combine
import CoreLocation
import Foundation
import UniformTypeIdentifiers

import FrontmatterSwift
import Interact

public class Library: @unchecked Sendable {

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

    private let directoryMonitor: DirectoryMonitor
    private let workQueue = DispatchQueue(label: "Library.workQueue")

    private var files: [Details.Identifier: [String]] = [:]

    @MainActor public var tags = Trie()

    public init(rootURL: URL) {
        self.rootURL = rootURL
        self.directoryMonitor = try! DirectoryMonitor(url: rootURL, queue: workQueue)
        self.directoryMonitor.delegate = self
    }

    public func start() {
        self.directoryMonitor.start()
        workQueue.async {
            self.workQueue_updateTags()
        }
    }

    private func workQueue_updateTags() {
        dispatchPrecondition(condition: .onQueue(workQueue))

        // Reload the tags.
        let fileManager = FileManager.default
        let files = Set(try! fileManager
            .files(directoryURL: rootURL)
            .filter {
                $0.contentType.conforms(to: .markdown)
            }
        )
        self.files = files.reduce(into: [Details.Identifier: [String]]()) { partialResult, details in
            partialResult[details.identifier] = Self.tags(for: details.url)
        }

        // Generate the full set of tags.
        let tags = self.files.values.reduce(into: Set<String>()) { partialResult, tags in
            partialResult.formUnion(tags)
        }

        // Construct a trie for quick lookup.
        let trie = Trie(words: tags)
        DispatchQueue.main.async {
            self.tags = trie
        }
    }

    public func stop() {
        directoryMonitor.cancel()
    }

}

extension Library: DirectoryMonitorDelegate {

    public func directoryMonitor(_ directoryMonitor: DirectoryMonitor, contentsDidChangeForUrl url: URL) {
        self.workQueue_updateTags()
    }

}
