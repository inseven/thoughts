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

struct ContentView: View {

    var applicationModel: ApplicationModel

    var systemImage: String {
        if applicationModel.shouldSaveLocation {
            if applicationModel.document.location != nil {
                return "location.fill"
            } else {
                return "location"
            }
        } else {
            return "location.slash"
        }
    }

    var body: some View {
        HStack {
            if applicationModel.rootURL != nil {
                ComposeView(applicationModel: applicationModel)
            } else {
                ContentUnavailableView {
                    Label("No Folder Set", systemImage: "folder")
                } description: {
                    Text("Select a folder to store your notes.")
                    Button {
                        applicationModel.setRootURL()
                    } label: {
                        Text("Set Notes Folder")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    applicationModel.shouldSaveLocation.toggle()
                } label: {
                    let hasLocation = applicationModel.document.location != nil
                    Label("Use Location", systemImage: systemImage)
                        .foregroundColor(hasLocation ? .purple : nil)
                }
                .disabled(applicationModel.rootURL == nil)
            }
        }
    }


}
