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

import Foundation

@testable import Thoughts

extension Date {

    init(_ year: Int,
         _ month: Int,
         _ day: Int,
         _ hour: Int = 0,
         _ minute: Int = 0,
         _ second: Int = 0,
         _ millisecond: Int = 0,
         timeZone: TimeZone = .gmt) {
        let dateComponents = DateComponents(year: year,
                                            month: month,
                                            day: day,
                                            hour: hour,
                                            minute: minute,
                                            second: second,
                                            nanosecond: millisecond * 1000000)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self = calendar.date(from: dateComponents)!
    }

}

extension RegionalDate {

    init(_ year: Int,
         _ month: Int,
         _ day: Int,
         _ hour: Int = 0,
         _ minute: Int = 0,
         _ second: Int = 0,
         _ millisecond: Int = 0,
         timeZone: TimeZone = .gmt) {
        self.init(Date(year, month, day, hour, minute, second, millisecond, timeZone: timeZone),
                  timeZone: timeZone)
    }

}
