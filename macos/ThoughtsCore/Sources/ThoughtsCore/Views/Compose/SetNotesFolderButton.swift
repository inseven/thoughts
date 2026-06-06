// Copyright (c) 2021-2026 Jason Morley
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

public struct SetNotesFolderButton: View {

    @Environment(ApplicationModel.self) private var applicationModel

    @State var showFileImporter = false

    let completion: () -> Void

    public init(completion: @escaping () -> Void = {}) {
        self.completion = completion
    }

    public var body: some View {
        Button("Set Notes Folder") {
            showFileImporter = true
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.folder]) { result in
            guard case .success(let url) = result else {
                return
            }
            applicationModel.rootURL = url
            completion()
        }
    }

}
