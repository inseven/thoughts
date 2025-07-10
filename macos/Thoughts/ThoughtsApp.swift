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
import HotKey
import Glitter
import Interact

@main
struct ThoughtsApp: App {

    static let title = "Thoughts Support (\(Bundle.main.extendedVersion ?? "Unknown Version"))"

    var applicationModel: ApplicationModel
    let hotKey: HotKey

    init() {
        let applicationModel = ApplicationModel()
        let hotKey = HotKey(key: .t, modifiers: [.command, .option, .control], keyDownHandler: {
           applicationModel.new()
       })
        self.applicationModel = applicationModel
        self.hotKey = hotKey
    }

    var body: some Scene {

        MenuBarExtra {
            MainMenu(applicationModel: applicationModel)
        } label: {
            Image(systemName: "text.justify.left")
        }
        .commands {
            ThoughtsCommands(applicationModel: applicationModel)
            UpdateCommands(updater: applicationModel.updaterController.updater)
        }

        ComposeWindow()
            .environment(applicationModel)
            .handlesExternalEvents(matching: [.compose])
            .defaultSize(width: 800, height: 600)

        SettingsWindow()
            .environment(applicationModel)
            .handlesExternalEvents(matching: [.settings])

        About(repository: "inseven/thoughts", copyright: "Copyright © 2024-2025 Jason Morley") {
            Action("Website", url: URL(string: "https://thoughts.jbmorley.co.uk")!)
            Action("Privacy Policy", url: URL(string: "https://thoughts.jbmorley.co.uk/privacy-policy")!)
            Action("GitHub", url: URL(string: "https://github.com/inseven/thoughts")!)
            Action("Support", url: URL(address: "support@jbmorley.co.uk", subject: Self.title)!)
        } acknowledgements: {
            Acknowledgements("Developers") {
                Credit("Jason Morley", url: URL(string: "https://jbmorley.co.uk"))
            }
            Acknowledgements("Thanks") {
                Credit("Joanne Wong")
                Credit("Jon Mountjoy")
                Credit("Lukas Fittl")
                Credit("Matt Sephton")
                Credit("Mike Rhodes")
                Credit("Pavlos Vinieratos")
                Credit("Sarah Barbour")
            }
        } licenses: {
            (.thoughts)
        }
        .handlesExternalEvents(matching: [.about])

    }
}
