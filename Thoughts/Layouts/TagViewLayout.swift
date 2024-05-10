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

fileprivate extension LayoutSubviews {

    typealias SubviewDetails = (LayoutSubviews.Element, CGSize)

    func rows(proposal: ProposedViewSize, spacing: CGFloat) -> [[SubviewDetails]] {
        guard let width = proposal.width else {
            return [[]]
        }

        let details = self.map {
            return ($0, $0.sizeThatFits(.unspecified))
        }

        var rows: [[SubviewDetails]] = []
        var row: [SubviewDetails] = []
        var rowWidth: CGFloat = -spacing
        for (index, (subview, size)) in details.enumerated() {
            if rowWidth + spacing + size.width > width {
                rows.append(row)
                row = []
                rowWidth = 0.0
            }

            // We treat the last element differently to force it to fill the entire space since we know it's the text
            // entry field.
            if index + 1 >= details.count {
                let size = CGSize(width: width - rowWidth - spacing, height: size.height)
                row.append((subview, size))
                rowWidth += spacing + size.width
            } else {
                row.append((subview, size))
                rowWidth += spacing + size.width
            }
        }
        if !row.isEmpty {
            rows.append(row)
        }
        return rows
    }

}

struct TagViewLayout: Layout {

    let spacing: CGFloat

    init(spacing: CGFloat) {
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = subviews.rows(proposal: proposal, spacing: spacing)

        let width = rows
            .map { row in
                row.map { subview, size in
                    size.width
                }
                .reduce(0.0, +)
            }
            .reduce(0.0, max)

        let height = rows
            .map { row in
                row.map { subview, size in
                    size.height
                }
                .reduce(0.0, max)
            }
            .reduce(0.0, +)

        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var posY = bounds.minY
        for row in subviews.rows(proposal: proposal, spacing: spacing) {
            let rowHeight = row.map({ $1.height }).reduce(0.0, max)
            var posX = bounds.minX
            for (subview, size) in row {
                subview.place(at: CGPoint(x: posX, y: posY + rowHeight),
                              anchor: .bottomLeading,
                              proposal: ProposedViewSize(size))
                posX += size.width + spacing
            }
            posY += rowHeight
        }
    }
}
