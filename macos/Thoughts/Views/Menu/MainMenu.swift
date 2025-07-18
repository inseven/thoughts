// Copyright (c) 2024-2025 Jason Morley
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

import Diligence

#if canImport(Glitter)
import Glitter
#endif

struct MainMenu: View {

    var applicationModel: ApplicationModel

    @Environment(\.openURL) var openURL

    var body: some View {

        Button("New...") {
            applicationModel.new()
        }
        .keyboardShortcut("t", modifiers: [.command, .option, .control])
        .disabled(!applicationModel.didShowIntroduction)

        Divider()

        Button {
            openURL(.about)
        } label: {
            Text("About...")
        }
        Button {
            openURL(.settings)
        } label: {
            Text("Settings...")
        }
        .keyboardShortcut(",")
        .disabled(!applicationModel.didShowIntroduction)

        Divider()

#if canImport(Glitter)

            UpdateLink(updater: applicationModel.updaterController.updater)

            Divider()
#endif

#if DEBUG

        Button {
            applicationModel.showIntroduction()
        } label: {
            Text("Introduction...")
        }

        Divider()
#endif

        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text("Quit")
        }
        .keyboardShortcut("q")
    }

}
