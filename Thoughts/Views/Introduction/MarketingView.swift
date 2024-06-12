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

struct MarketingView<Content: View, Header: View, Footer: View>: View {

    let title: String
    let subtitle: String?

    let content: Content
    let header: Header
    let footer: Footer

    init(_ title: String,
         subtitle: String? = nil,
         @ViewBuilder content: () -> Content,
         @ViewBuilder header: () -> Header,
         @ViewBuilder footer: () -> Footer) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.header = header()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
            content
                .font(.title3)
                .textSelection(.enabled)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 420)
            .controlSize(.large)
            Spacer()
            footer
                .foregroundStyle(.secondary)
                .font(.footnote)
                .textSelection(.enabled)
        }
    }

}

extension MarketingView where Footer == EmptyView {

    init(_ title: String,
         subtitle: String? = nil,
         @ViewBuilder content: () -> Content,
         @ViewBuilder header: () -> Header) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.header = header()
        self.footer = EmptyView()
    }

}

extension MarketingView where Header == SymbolHeader {

    init(_ title: String,
         subtitle: String? = nil,
         systemImage: String,
         @ViewBuilder content: () -> Content,
         @ViewBuilder footer: () -> Footer) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.header = SymbolHeader(systemImage: systemImage)
        self.footer = footer()
    }

}

extension MarketingView where Header == SymbolHeader, Footer == EmptyView {

    init(_ title: String,
         subtitle: String? = nil,
         systemImage: String,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.header = SymbolHeader(systemImage: systemImage)
        self.footer = EmptyView()
    }

}
