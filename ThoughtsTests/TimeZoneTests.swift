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
