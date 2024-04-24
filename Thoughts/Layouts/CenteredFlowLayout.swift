// Copyright (c) 2022-2024 Jason Morley
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

extension LayoutSubviews {

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
        for (subview, size) in details {
            if rowWidth + spacing + size.width > width {
                rows.append(row)
                row = []
                rowWidth = 0.0
            }
            row.append((subview, size))
            rowWidth += spacing + size.width
        }
        if !row.isEmpty {
            rows.append(row)
        }
        return rows
    }

}

struct CenteredFlowLayout: Layout {

    let spacing: CGFloat = 4.0

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

        print("size = (\(width), \(height))")

        return CGSize(width: width, height: height)
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
