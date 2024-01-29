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

import Foundation

struct Document {

    static func header(for date: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = Calendar.current.timeZone
        let dateString = dateFormatter.string(from: date)
        return "---\ndate: \(dateString)\n---\n\n"
    }

    var date: Date
    var content: String

    var url: URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        formatter.timeZone = .gmt
        let filename = formatter.string(from: date)
        return ApplicationModel.folderURL.appendingPathComponent(filename).appendingPathExtension("md")
    }

    var isEmpty: Bool {
        return content.isEmpty
    }

    init(date: Date = Date()) {
        self.date = date
        self.content = ""
    }

    func save() throws {
        let content = Self.header(for: date) + self.content
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

}
