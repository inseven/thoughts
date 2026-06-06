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

import ThoughtsCore


struct IntroductionView: View {

    @Environment(\.dismiss) private var dismiss

    let applicationModel: ApplicationModel

    var body: some View {
        Button("Done") {
            applicationModel.introductionVersion = ApplicationModel.introductionVersion
            applicationModel.new()
            dismiss()
        }
        .navigationTitle("Introduction")
    }

}


@main
struct ThoughtsApp: App {

    enum SheetType: Identifiable {

        var id: Self {
            return self
        }

        case introduction
    }

    class ModelDelegate: NSObject, ApplicationModelDelegate {

        func showIntroduction(applicationModel: ApplicationModel) {
//            let window = NSIntroductionWindow(applicationModel: applicationModel)
//            window.center()
//            window.makeKeyAndOrderFront(nil)
        }

        func showUpdateAlert(applicationModel: ApplicationModel) {
//            let alert = NSAlert()
//            alert.alertStyle = .informational
//            alert.messageText = "Update Available"
//            alert.informativeText = "Thoughts is no longer being updated on the Mac App Store. Please download the latest update from the website."
//            alert.showsSuppressionButton = true
//            _ = alert.addButton(withTitle: "OK")
//            alert.runModal()
//            let suppressionState = alert.suppressionButton?.state as? NSControl.StateValue ?? .off
//            applicationModel.suppressUpdateCheck = suppressionState == .on
        }

        func setRootURL(applicationModel: ApplicationModel) -> Bool {
//            dispatchPrecondition(condition: .onQueue(.main))
//            let openPanel = NSOpenPanel()
//            openPanel.canChooseFiles = false
//            openPanel.canChooseDirectories = true
//            openPanel.canCreateDirectories = true
//            guard openPanel.runModal() ==  NSApplication.ModalResponse.OK,
//                  let url = openPanel.url else {
//                return false
//            }
//            applicationModel.rootURL = url
//            applicationModel.document = Document()
//            return true
            return false
        }

        func showThought(applicationModel: ApplicationModel) {
//            NSWorkspace.shared.open(.compose)
        }

    }

    @Environment(\.scenePhase) private var scenePhase

    @State private var sheet: SheetType?

    var applicationModel: ApplicationModel
    var modelDelegate: ModelDelegate

    init() {
        let applicationModel = ApplicationModel()
        let modelDelegate = ModelDelegate()
        applicationModel.delegate = modelDelegate
        self.applicationModel = applicationModel
        self.modelDelegate = modelDelegate
        self.applicationModel.start()

//        self.applicationModel.new()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(applicationModel: applicationModel)
                    .navigationBarTitleDisplayMode(.inline)
                    .sheet(item: $sheet) { sheet in
                        switch sheet {
                        case .introduction:
                            NavigationView {
                                IntroductionView(applicationModel: applicationModel)
                            }
                        }
                    }
            }
        }
        .onChange(of: applicationModel.didShowIntroduction, initial: true) { _, didShowIntroduction in
            guard !didShowIntroduction else {
                return
            }
            sheet = .introduction
        }
        .onChange(of: scenePhase) { _, scenePhase in
            switch scenePhase {
            case .background, .inactive:
                applicationModel.lastBackgroundDate = min(Date(), applicationModel.lastBackgroundDate)
            case .active:
                let backgroundDuration = applicationModel.lastBackgroundDate.timeIntervalSinceNow * -1
                print("Opened after \(backgroundDuration) seconds.")
                guard backgroundDuration > 60 * 5 else {
                    break
                }
                print("Creating new thought...")
                applicationModel.lastBackgroundDate = Date.distantFuture
                applicationModel.new()
            @unknown default:
                break
            }
        }
    }
}
