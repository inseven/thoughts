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

    @ObservedObject var applicationModel: ApplicationModel
    @StateObject var composeModel: ComposeModel

    init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
        _composeModel = StateObject(wrappedValue: ComposeModel(applicationModel: applicationModel))
    }

    var body: some View {
        VStack {
            TextEditor(text: $applicationModel.document.content)
                .scrollContentBackground(.hidden)
                .frame(minWidth: 400)
                .font(.system(size: 14, design: .monospaced))
            TextField("Tags", text: $applicationModel.document.tags)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .navigationTitle(applicationModel.document.date.formatted())
        .presents($composeModel.error)
        .onAppear {
            composeModel.start()
        }
        .onDisappear {
            composeModel.stop()
        }
    }

}
