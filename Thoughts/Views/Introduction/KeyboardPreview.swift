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

struct KeyboardPreview: View {

    struct Key: View {

        struct LayoutMetrics {
            static let unitWidth = 56.0
            static let unitHeight = 56.0
            static let cornerRadius = 4.0
            static let padding = 6.0
        }

        let legend: String
        let text: String?
        let width: CGFloat

        init(_ legend: String, text: String? = nil, width: CGFloat = 1.0) {
            self.legend = legend
            self.text = text
            self.width = width
        }

        var body: some View {
            VStack(alignment: .trailing) {
                if let text {
                    HStack {
                        Spacer()
                        Text(legend)
                            .font(.title2)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text(text)
                            .font(.footnote)
                    }
                } else {
                    Text(legend)
                        .font(.title2)
                }
            }
            .padding(LayoutMetrics.padding)
            .frame(width: LayoutMetrics.unitWidth * width,
                   height: LayoutMetrics.unitHeight)
            .background(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius)
                .fill(.secondary)
                .foregroundStyle(.tint))
        }

    }

    var body: some View {
        HStack {
            Key("⌃", text: "control")
            Key("⌥", text: "option")
            Key("⌘", text: "command", width: 1.25)
            Text("+")
                .font(.title)
            Key("T")
        }
        .preview()
    }

}

#Preview {
    KeyboardPreview()
}
