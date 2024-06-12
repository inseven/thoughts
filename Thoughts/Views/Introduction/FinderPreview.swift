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

import SwiftUI

import Interact

struct FinderPreview: View {

    struct FinderRow: View {

        let title: String

        init(_ title: String) {
            self.title = title
        }

        var body: some View {
            HStack(spacing: 4) {
                Image(nsImage: NSWorkspace.shared.icon(for: .markdown))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                Text(title)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(2)
            .frame(maxWidth: 320)
        }

    }

    var body: some View {
        VStack(spacing: 1) {
            FinderRow("2024-05-31-06-28-55.md")
            FinderRow("2024-05-31-06-29-11.md")
                .background(Color(NSColor.unemphasizedSelectedTextBackgroundColor)
                    .cornerRadius(4))
            FinderRow("2024-05-31-06-57-27.md")
            FinderRow("2024-06-06-01-08-33.md")
        }
        .padding()
        .preview()
    }

}
