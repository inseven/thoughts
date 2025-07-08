import CoreLocation
import Foundation

// https://stackoverflow.com/questions/50384494/swift-retrieve-timezone-from-iso8601-date-string
extension TimeZone {
    /// Pattern that grabs the time zone from iso8601 strings
    /// This needs to handle the following cases:
    /// `<time>Z`
    /// `<time>±hh`
    /// `<time>±hhmm`
    /// `<time>±hh:mm`
    /// See https://en.wikipedia.org/wiki/ISO_8601#Time_zone_designators .
    private static let iso8601TzPattern = /T[\d:.,]+([\+±−-])(\d\d):?(\d\d)?$/

    /// Extracts the time zone from an iso8601 formatted date string.
    init?(iso8601: String) {
        if iso8601.hasSuffix("Z") { // Zulu (UTC)
            self.init(secondsFromGMT: 0)
            return
        }

        guard let matches = try? Self.iso8601TzPattern.firstMatch(in: iso8601),
              let hours = Int(matches.2) else {
            return nil
        }

        // offset from GMT in seconds
        var offset = hours * 3600

        if let minutesString = matches.3, let minutes = Int(minutesString) {
            offset += minutes * 60
        }

        // sign
        switch matches.1 {
        // minus sign and hyphen-minus (not the same)
        case "−", "-":
            offset = -offset
        case "±":
            if offset != 0 {
                // only allowed for zero offset
                return nil
            }
        default: break
        }

        self.init(secondsFromGMT: offset)
    }
}
