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

import Diligence
import Interact

@main
struct ThoughtsApp: App {

    var applicationModel = ApplicationModel()

    var body: some Scene {

        MenuBarExtra {
            MainMenu(applicationModel: applicationModel)
        } label: {
            Image(systemName: "text.justify.left")
        }

        ComposeWindow()
            .environmentObject(applicationModel)
            .handlesExternalEvents(matching: [.compose])
            .defaultSize(width: 800, height: 600)

        Settings {
            SettingsView(applicationModel: applicationModel)
        }

        let title = "Thoughts Support (\(Bundle.main.version ?? "Unknown Version"))"

        About(repository: "inseven/thoughts", copyright: "Copyright © 2024 Jason Morley") {
            Diligence.Action("GitHub", url: URL(string: "https://github.com/inseven/thoughts")!)
            Diligence.Action("Support", url: URL(address: "support@jbmorley.co.uk", subject: title)!)
        } acknowledgements: {
            Acknowledgements("Developers") {
                Credit("Jason Morley", url: URL(string: "https://jbmorley.co.uk"))
            }
            Acknowledgements("Thanks") {
                Credit("Lukas Fittl")
                Credit("Sarah Barbour")
            }
        } licenses: {
            .interact
            License("Material Icons", author: "Google", filename: "material-icons-license")
            License("Thoughts", author: "Jason Morley", filename: "thoughts-license")
        }
        .handlesExternalEvents(matching: [.about])

    }
}
