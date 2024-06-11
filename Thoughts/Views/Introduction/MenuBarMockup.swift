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

struct FakeMenuRow: View {

    let label: String
    let shortcut: String?
    let isSelected: Bool

    init(_ label: String, shortcut: String? = nil, isSelected: Bool = false) {
        self.label = label
        self.shortcut = shortcut
        self.isSelected = isSelected
    }

    var body: some View {
        HStack {
            HStack {
                Text(label)
                Spacer()
                if let shortcut {
                    Text(shortcut)
                        .foregroundStyle(.secondary)
//                        .foregroundStyle(isSelected ? .white : .secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color(nsColor: .selectedControlColor) : .clear))
//            .foregroundStyle(isSelected ? .white : .primary,
//                             isSelected ? .white : .secondary)
        }
    }

}

struct MenuBarMockup: View {

    var body: some View {

        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                HStack {
                    Spacer()
                }
                HStack {
                    Image(systemName: "text.justify.left")
                        .shadow(radius: 1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Rectangle()
                            .fill(.tertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 4)))
                    Spacer()
                }
                .padding(.horizontal, 4)
                HStack {
                    Spacer()
                    Text("Thu 14:40")
                        .foregroundStyle(.tertiary)
                }
            }
            GridRow {
                Divider()
                    .padding(.vertical, 4)
                    .gridCellColumns(3)
            }
            GridRow {
                HStack {
                    Spacer()
                }
                HStack {
                    VStack(spacing: 2) {
                        FakeMenuRow("New…", shortcut: "⌃⌥⌘T", isSelected: true)
                        Divider()
                        FakeMenuRow("About…")
                        FakeMenuRow("Settings…", shortcut: "⌘,")
                        Divider()
                        FakeMenuRow("Quit", shortcut: "⌘Q")
                    }
                    .frame(maxWidth: 300)
                    .padding(6)
//                    .background(.thickMaterial)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke().foregroundStyle(.tertiary))
//                    .shadow(radius: 10)
                }
                .padding(.bottom)
                HStack {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .padding()
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(16)
        .font(.body)

//        ZStack {
//            VStack(spacing: 0) {
//                HStack {
//                    Spacer()
//                    Image(systemName: "text.justify.left")
//                        .padding()
////                        .background(.pink)
//                    Spacer()
//                    Text("Thu 14:40")
//                        .padding()
//                }
////                .background(.thinMaterial)
//                .background(.gray)
//                Divider()
//                HStack {
//                    VStack {
//                        HStack {
//                            Text("New...")
//                            Spacer()
//                            Text("⌃⌥⌘T")
//                                .foregroundStyle(.tertiary)
//                        }
//                        .background(Color(nsColor: .selectedControlColor))
//                        .foregroundStyle(.white, .white, .white)
//                        Divider()
//                        HStack {
//                            Text("About...")
//                            Spacer()
//                        }
//                        HStack {
//                            Text("Settings...")
//                            Spacer()
//                            Text("⌘,")
//                                .foregroundStyle(.tertiary)
//                        }
//                        Divider()
//                        HStack {
//                            Text("Quit")
//                            Spacer()
//                            Text("⌘Q")
//                                .foregroundStyle(.tertiary)
//                        }
//                    }
//                    .frame(maxWidth: 300)
//                    .padding()
//                    .background(.thickMaterial)
//                    .cornerRadius(8)
//                    .overlay(RoundedRectangle(cornerRadius: 8).stroke().foregroundStyle(.tertiary))
//                    .shadow(radius: 10)
//                }
//                .padding(.bottom)
//            }
//        }
//        .background(Image("Background").resizable())
//        .cornerRadius(16)
    }

}

#Preview {
    MenuBarMockup()
}
