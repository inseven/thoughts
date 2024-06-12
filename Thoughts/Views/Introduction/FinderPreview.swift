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

    struct LayoutMetrics {

        static let iconSize = 16.0

    }

    struct FinderRow: View {

        let title: String
        let isSelected: Bool

        init(_ title: String, isSelected: Bool = false) {
            self.title = title
            self.isSelected = isSelected
        }

        var body: some View {
            HStack(spacing: 4) {
                Image(nsImage: NSWorkspace.shared.icon(for: .markdown))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: LayoutMetrics.iconSize, height: LayoutMetrics.iconSize)
                Text(title)
                Spacer()
            }
            .selection(insets: EdgeInsets(horizontal: 2, vertical: 2), cornerRadius: 4.0, isSelected: isSelected)
        }

    }

    var body: some View {
        VStack(spacing: 1) {
            FinderRow("2024-05-31-06-28-55.md")
            FinderRow("2024-05-31-06-29-11.md")
            FinderRow("2024-05-31-06-57-27.md")
            FinderRow("2024-06-06-01-08-33.md", isSelected: true)
        }
        .frame(maxWidth: 320)
        .padding()
        .preview()
    }

}

#Preview {
    FinderPreview()
}
