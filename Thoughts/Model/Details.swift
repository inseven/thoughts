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

struct Details: Hashable {

    // TODO: This isn't really an identifier anymore is it.
    struct Identifier: Equatable, Hashable {
        let ownerURL: URL
        let url: URL

        var parent: Identifier {
            return Identifier(ownerURL: ownerURL, url: url.deletingLastPathComponent())
        }
    }

    let identifier: Identifier
    let ownerURL: URL
    let uuid: UUID
    let url: URL
    let contentType: UTType

    // Even though modern Swift APIs expose the content modification date, round-tripping this into SQLite looses
    // precision causing us to incorrectly think files have changed. To make it much harder to make this mistake, we
    // instead store the contentModificationDate as an Int which represents milliseconds since the reference data.
    let contentModificationDate: Int

    init(uuid: UUID, ownerURL: URL, url: URL, contentType: UTType, contentModificationDate: Int) {
        self.uuid = uuid
        self.identifier = Identifier(ownerURL: ownerURL, url: url)
        self.ownerURL = ownerURL
        self.url = url
        self.contentType = contentType
        self.contentModificationDate = contentModificationDate
    }

    var parentURL: URL {
        return url.deletingLastPathComponent()
    }

    func setting(ownerURL: URL) -> Details {
        return Details(uuid: uuid,
                       ownerURL: ownerURL,
                       url: url,
                       contentType: contentType,
                       contentModificationDate: contentModificationDate)
    }

    func equivalent(to details: Details) -> Bool {
        // TODO: Does the content type ever change?
        // TODO: Function overload?
        return (ownerURL == details.ownerURL &&
                url == details.url &&
                contentType == details.contentType &&
                contentModificationDate == details.contentModificationDate)
    }

    func applying(details: Details) -> Details {
        return Details(uuid: uuid,
                       ownerURL: ownerURL,
                       url: url,
                       contentType: contentType,
                       contentModificationDate: details.contentModificationDate)
    }

}
