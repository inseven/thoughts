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

import SwiftUI
import UniformTypeIdentifiers

extension URL {

    public static let donate = URL(string: "https://jbmorley.co.uk/support")!

    public static let about = URL(string: "x-thoughts://about")!
    public static let compose = URL(string: "x-thoughts://compose")!
    public static let settings = URL(string: "x-thoughts://settings")!

    public var contentModificationDate: Date? {
        get throws {
            return try resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        }
    }

    public var contentType: UTType? {
        get throws {
            return try resourceValues(forKeys: [.contentTypeKey]).contentType
        }
    }

    public var isDirectory: Bool? {
        get throws {
            return try resourceValues(forKeys: [.isDirectoryKey]).isDirectory
        }
    }

//    public init(filePath: String, itemType: FSEvent.ItemType) {
//        self.init(filePath: filePath, directoryHint: itemType == .dir ? .isDirectory : .notDirectory)
//    }

}
