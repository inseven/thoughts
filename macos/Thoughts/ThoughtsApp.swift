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

import Diligence
import HotKey
import Interact

#if canImport(Glitter)
import Glitter
#endif

import ThoughtsCore

@main
struct ThoughtsApp: App {

    class ModelDelegate: NSObject, ApplicationModelDelegate {

        func showIntroduction(applicationModel: ApplicationModel) {
            let window = NSIntroductionWindow(applicationModel: applicationModel)
            window.center()
            window.makeKeyAndOrderFront(nil)
        }

        func showUpdateAlert(applicationModel: ApplicationModel) {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Update Available"
            alert.informativeText = "Thoughts is no longer being updated on the Mac App Store. Please download the latest update from the website."
            alert.showsSuppressionButton = true
            _ = alert.addButton(withTitle: "OK")
            alert.runModal()
            let suppressionState = alert.suppressionButton?.state as? NSControl.StateValue ?? .off
            applicationModel.suppressUpdateCheck = suppressionState == .on
        }

        func setRootURL(applicationModel: ApplicationModel) -> Bool {
            dispatchPrecondition(condition: .onQueue(.main))
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            guard openPanel.runModal() ==  NSApplication.ModalResponse.OK,
                  let url = openPanel.url else {
                return false
            }
            applicationModel.rootURL = url
            applicationModel.document = Document()
            return true
        }

    }

    static let title = "Thoughts Support (\(Bundle.main.extendedVersion ?? "Unknown Version"))"

    var applicationModel: ApplicationModel
    var modelDelegate: ModelDelegate
    let hotKey: HotKey

    init() {
        let applicationModel = ApplicationModel()
        let modelDelegate = ModelDelegate()
        let hotKey = HotKey(key: .t, modifiers: [.command, .option, .control], keyDownHandler: {
            applicationModel.new()
        })
        applicationModel.delegate = modelDelegate
        self.applicationModel = applicationModel
        self.modelDelegate = modelDelegate
        self.hotKey = hotKey
        self.applicationModel.start()
    }

    var body: some Scene {

        MenuBarExtra {
            MainMenu(applicationModel: applicationModel)
        } label: {
            Image(systemName: "text.justify.left")
        }
        .commands {
            ThoughtsCommands(applicationModel: applicationModel)
#if canImport(Glitter)
            UpdateCommands(updater: applicationModel.updaterController.updater)
#endif
        }

        ComposeWindow()
            .environment(applicationModel)
            .handlesExternalEvents(matching: [.compose])
            .defaultSize(width: 800, height: 600)

        SettingsWindow()
            .environment(applicationModel)
            .handlesExternalEvents(matching: [.settings])

        About(repository: "inseven/thoughts", copyright: "Copyright © 2021-2026 Jason Morley") {
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
