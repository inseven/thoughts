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

struct RegionalDate: Codable, Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.date != rhs.date {
            return false
        }
        if lhs.timeZone.secondsFromGMT() != rhs.timeZone.secondsFromGMT() {
            return false
        }
        return true
    }

    let date: Date
    let timeZone: TimeZone

    init(_ date: Date, timeZone: TimeZone) {
        self.date = date
        self.timeZone = timeZone
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: string) else {
            throw ThoughtsError.encodingError
        }
        self.date = date
        self.timeZone = TimeZone(iso8601: string) ?? .gmt
    }

    func encode(to encoder: any Encoder) throws {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = timeZone
        var container = encoder.singleValueContainer()
        try container.encode(dateFormatter.string(from: date))
    }

}
