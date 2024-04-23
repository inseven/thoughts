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

import CoreLocation
import Foundation

import Yams

struct Document {

    var date: Date
    var content: String
    var tags: String
    var location: Location? = nil

    var isEmpty: Bool {
        return content.isEmpty
    }

    init(date: Date = Date()) {
        self.date = date
        self.content = ""
        self.tags = ""
    }

    func header() -> String {
        do {
            let tags = tags
                .split(separator: /\s+/)
                .map { String($0)}
            let metadata = Metadata(date: RegionalDate(date, timeZone: .current),
                                    tags: tags,
                                    location: location)
            let encoder = YAMLEncoder()
            let frontmatter = try encoder.encode(metadata)
            return "---\n\(frontmatter)\n---\n"
        } catch {
            print("Failed to encode metadata with error \(error).")
            return ""
        }
    }

    func sync(to rootURL: URL) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        formatter.timeZone = .gmt
        let filename = formatter.string(from: date)
        let url = rootURL.appendingPathComponent(filename).appendingPathExtension("md")
        if isEmpty {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        } else {
            let content = header() + self.content
            try content.write(to: url, atomically: true, encoding: .utf8)
        }
    }

}
