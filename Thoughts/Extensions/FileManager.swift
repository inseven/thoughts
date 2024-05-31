// MIT License
//
// Copyright (c) 2023-2024 Jason Morley
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

import Foundation
import UniformTypeIdentifiers

extension FileManager {

    func details(for path: String, owner: URL) throws -> Details {
        let url = URL(filePath: path)
        return try details(for: url, owner: owner)
    }

    func details(for url: URL, owner: URL) throws -> Details {
        guard let isDirectory = try url.isDirectory else {
            throw ThoughtsError.accessError
        }

        guard let contentType = try url.contentType else {
            throw ThoughtsError.accessError
        }

        guard let contentModificationDate = try url.contentModificationDate else {
            throw ThoughtsError.accessError
        }

        return Details(uuid: UUID(),
                       ownerURL: owner,
                       url: url,
                       contentType: isDirectory ? .directory : contentType,
                       contentModificationDate: contentModificationDate.millisecondsSinceReferenceDate)
    }

    // Returns all the files contained within directoryURL, including the root.
    func files(directoryURL: URL, ownerURL: URL? = nil) throws -> [Details]  {
        precondition(directoryURL.hasDirectoryPath)
        precondition(ownerURL?.hasDirectoryPath ?? true)
        let date = Date()
        let resourceKeys = Set<URLResourceKey>([.nameKey,
                                                .isDirectoryKey,
                                                .contentTypeKey,
                                                .contentModificationDateKey])
        let directoryEnumerator = enumerator(at: directoryURL,
                                             includingPropertiesForKeys: Array(resourceKeys),
                                             options: [.skipsHiddenFiles])!

        var files: [Details] = [try details(for: directoryURL, owner: ownerURL ?? directoryURL)]
        for case let fileURL as URL in directoryEnumerator {
            guard let contentType = try fileURL.contentType,
                  let contentModificationDate = try fileURL.contentModificationDate
            else {
                print("Failed to determine content type for \(fileURL).")
                continue
            }
            files.append(Details(uuid: UUID(),
                                 ownerURL: ownerURL ?? directoryURL,
                                 url: fileURL,
                                 contentType: contentType,
                                 contentModificationDate: contentModificationDate.millisecondsSinceReferenceDate))
        }

        let duration = date.distance(to: Date())
        print("Listing for '\(directoryURL.displayName)' took \(duration.formatted()) seconds (\(files.count) files).")

        return files
    }

}
