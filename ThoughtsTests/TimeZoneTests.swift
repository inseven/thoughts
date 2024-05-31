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

import XCTest

@testable import Thoughts

// https://stackoverflow.com/questions/50384494/swift-retrieve-timezone-from-iso8601-date-string
final class TimeZoneTests : XCTestCase {

    func testISO8601() {
        // valid time zones
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45+01"), TimeZone(hours: 1, minutes: 0))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45+01:00"), TimeZone(hours: 1, minutes: 0))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24+01:00"), TimeZone(hours: 1, minutes: 0))

        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45+12:34"), TimeZone(hours: 12, minutes: 34))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24+1234"), TimeZone(hours: 12, minutes: 34))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24+12:34"), TimeZone(hours: 12, minutes: 34))

        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45-12:34"), TimeZone(hours: -12, minutes: -34))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24-1234"), TimeZone(hours: -12, minutes: -34))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24-12:34"), TimeZone(hours: -12, minutes: -34))
        // minus sign instead of hyphen in the offset
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24−12:34"), TimeZone(hours: -12, minutes: -34))

        // Zulu (UTC)
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45Z"), TimeZone(secondsFromGMT: 0))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24Z"), TimeZone(secondsFromGMT: 0))
        XCTAssertEqual(TimeZone(iso8601: "2019-10-21T08:40:45.24±00"), TimeZone(secondsFromGMT: 0))

        // no time zone
        XCTAssertNil(TimeZone(iso8601: "2019-10-21"))
        XCTAssertNil(TimeZone(iso8601: "2019-10-21T08:40:45.24"))

        // invalid
        XCTAssertNil(TimeZone(iso8601: "2019-10-21T08:40:45.24±01"))
    }
}
