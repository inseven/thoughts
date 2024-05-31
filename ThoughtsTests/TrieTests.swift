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
final class TrieTests : XCTestCase {

    func testPrefix() {
        let trie = Trie(words: ["one", "two"])
        XCTAssertEqual(Set(trie.words(prefix: "")), Set(["one", "two"]))
        XCTAssertEqual(Set(trie.words(prefix: "o")), Set(["one"]))
        XCTAssertEqual(Set(trie.words(prefix: "t")), Set(["two"]))
        XCTAssertEqual(Set(trie.words(prefix: "th")), Set([]))

    }

    func testPrefixCollisions() {
        let trie = Trie(words: ["psion", "psion/series-5"])
        XCTAssertEqual(Set(trie.words(prefix: "")), Set(["psion", "psion/series-5"]))
        XCTAssertEqual(Set(trie.words(prefix: "p")), Set(["psion", "psion/series-5"]))
        XCTAssertEqual(Set(trie.words(prefix: "psion")), Set(["psion", "psion/series-5"]))
    }

}
