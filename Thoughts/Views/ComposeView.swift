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

struct ComposeView: View {

    var applicationModel: ApplicationModel

    init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
    }

    var body: some View {
        @Bindable var applicationModel = applicationModel
        VStack(spacing: 0) {
            TextEditor(text: $applicationModel.document.content)
                .scrollContentBackground(.hidden)
                .frame(minWidth: 400)
                .font(.system(size: 14, design: .monospaced))
                .monospaced()
                .edgesIgnoringSafeArea(.all)
            Divider()
            HStack {
                TextField("Tags", text: $applicationModel.document.tags)
                    .textFieldStyle(.plain)
                Spacer()
                HStack {
                    if let location = applicationModel.document.location {
                        if let locality = location.locality {
                            Text(locality)
                        } else if let latitude = location.latitude,
                                  let longitude = location.longitude {
                            Text("\(latitude), \(longitude)")
                        }
                    }
                }
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(.windowBackground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .navigationTitle(applicationModel.document.date.formatted(date: .complete, time: .standard))
    }

}
