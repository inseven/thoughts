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

import Interact

struct IntroductionView: View {

    @Environment(\.closeWindow) private var closeWindow

    let applicationModel: ApplicationModel

    enum PageIdentifier: Identifiable {

        var id: Self {
            return self
        }

        case welcome
        case folder
        case location
        case open
        case keyboard
    }

    @State var page: PageIdentifier = .welcome

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Pager($page) { page in
                    switch page {
                    case .welcome:
                        Page {
                            MarketingView("Welcome to Thoughts") {
                                Text("Thoughts is a lightweight note taking app. It works with your existing workflows to help you quickly get your ideas into the systems and tools you love.")
                                Text("Thoughts doesn't offer any viewing functionality—pair it with apps like [Obsidian](https://obsidian.md) and [Typora](https://typora.io) to organize and take your notes further.")
                            } header: {
                                Image("Icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 72, height: 72)
                            } footer: {
                                Text("Thoughts is not affiliated with Obsidian or Typora.")
                            }
                        } actions: {
                            Button("Continue") {
                                withAnimation {
                                    self.page = .folder
                                }
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    case .folder:
                        Page {
                            MarketingView("Capture Your Ideas", systemImage: "tray.and.arrow.down") {
                                Text("Thoughts stores all your notes in a folder of your choosing so you can easily integrate it with your exiting workflows.")
                                FinderPreview()
                            }
                        } actions: {
                            Button("Set Destination Folder") {
                                if applicationModel.setRootURL() {
                                    withAnimation {
                                        self.page = .location
                                    }
                                }
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    case .location:
                        Page {
                            MarketingView("Remember Your Location", systemImage: "location") {
                                Text("Thoughts can automatically store your location in Frontmatter so you never forget where you were when you had that important idea.")
                                LocationPreview()
                            } footer: {
                                Text("Thoughts never collects or stores your data. See our [Privacy Policy](https://thoughts.jbmorley.co.uk/#privacy-policy).")
                            }
                        } actions: {
                            Button("Skip") {
                                applicationModel.shouldSaveLocation = false
                                withAnimation {
                                    self.page = .open
                                }
                            }
                            .keyboardShortcut(.cancelAction)
                            Button("Save Locations") {
                                applicationModel.shouldSaveLocation = true
                                applicationModel.updateUserLocation {
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            self.page = .open
                                        }
                                    }
                                }
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    case .open:
                        Page {
                            MarketingView("Always Available", systemImage: "menubar.arrow.up.rectangle") {
                                Text("Thoughts lives in the Menu Bar, waiting for your notes.")
                                Text("Open at login to ensure you never miss something.")
                                MenuPreview()
                            } footer: {
                                Text("If you can't see the Thoughts icon in the Menu Bar, it might be hiding behind the notch. 👀")
                            }
                        } actions: {
                            Button("Skip") {
                                applicationModel.introductionVersion = ApplicationModel.introductionVersion
                                withAnimation {
                                    self.page = .keyboard
                                }
                            }
                            .keyboardShortcut(.cancelAction)
                            Button("Open at Login") {
                                Application.shared.openAtLogin = true
                                applicationModel.introductionVersion = ApplicationModel.introductionVersion
                                withAnimation {
                                    self.page = .keyboard
                                }
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    case .keyboard:
                        Page {
                            MarketingView("Keyboard First", systemImage: "keyboard") {
                                Text("Use global shortcuts to write and edit notes without taking your hands off the keyboard.")
                                KeyboardPreview()
                            }
                        } actions: {
                            Button("Start Writing") {
                                withAnimation {
                                    closeWindow()
                                    applicationModel.new()
                                }
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                }
            }
            .frame(width: 600, height: 600)
        }
    }

}
