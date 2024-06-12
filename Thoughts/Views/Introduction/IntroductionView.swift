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

import Interact

@Observable
class IntroductionModel {

    var openAtLogin: Bool = true
    var hasFolder: Bool = false
    var hasLocatonAccess: Bool = false

}

struct Page<Content: View, Actions: View> {

    let content: Content
    let actions: Actions

    init(@ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions) {
        self.content = content()
        self.actions = actions()
    }

}

struct AnyPage {

    let content: AnyView
    let actions: AnyView

    init<Content: View, Actions: View>(_ page: Page<Content, Actions>) {
        content = AnyView(page.content)
        actions = AnyView(page.actions)
    }

    init<Content: View, Actions: View>(@ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions) {
        self.content = AnyView(content())
        self.actions = AnyView(actions())
    }

}

// TODO How do I get this to accept any page construction?
struct Pager<Item: Identifiable & Hashable>: View {

    @Binding var item: Item

    let content: (Item) -> AnyPage

    init(_ item: Binding<Item>, content: @escaping (Item) -> AnyPage) {
        self._item = item
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            content(item).content
                .id(item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .transition(.push)
            HStack {
                Spacer()
                content(item).actions
                    .transition(.blurReplace())
            }
            .id(item)
            .controlSize(.large)
            .padding()
            .frame(maxWidth: .infinity)
        }
    }

}

struct FinderRow: View {

    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(nsImage: NSWorkspace.shared.icon(for: .markdown))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            Text(title)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .frame(maxWidth: 320)
    }

}

struct IntroductionView: View {

    @Environment(\.closeWindow) private var closeWindow

    @State var introductionModel = IntroductionModel()

    let applicationModel: ApplicationModel

    enum Page: Identifiable {

        var id: Self {
            return self
        }

        case welcome
        case folder
        case location
        case open
        case keyboard
    }

    @State var page: Page = .welcome
//    @State var page: Page = .keyboard

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Pager($page) { page in
                    switch page {
                    case .welcome:
                        AnyPage {
                            MarketingView(title: "Welcome to Thoughts") {
                                Text("Thoughts works with your workflows to help you quickly get your ideas into your existing systems and tools.")
                                Text("Pair it with apps like [Obsidian](https://obsidian.md) and [Typora](https://typora.io) to organize and take your notes further.")
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
                        AnyPage {
                            MarketingView(title: "Capture Your Ideas", systemImage: "tray.and.arrow.down") {
                                Text("Thoughts stores all your notes in a folder of your choosing so you can easily integrate it with your exiting workflows.")
                                VStack(spacing: 1) {
                                    FinderRow("2024-05-31-06-28-55.md")
                                    FinderRow("2024-05-31-06-29-11.md")
                                        .background(Color(NSColor.unemphasizedSelectedTextBackgroundColor)
                                            .cornerRadius(4))
                                    FinderRow("2024-05-31-06-57-27.md")
                                    FinderRow("2024-06-06-01-08-33.md")
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .padding()
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                            }
                        } actions: {
                            Button("Set Destination Folder") {
                                if applicationModel.setRootURL() {
                                    withAnimation {
                                        introductionModel.hasFolder = true
                                        self.page = .location
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                        }
                    case .location:
                        AnyPage {
                            MarketingView(title: "Remember Your Location", systemImage: "location") {
                                Text("Thoughts can store your location in Frontmatter so you never forget where you were when you had that important idea.")
                                HStack {
                                    Text("""
---
location:
  latitude: 2.15908069616624e+1
  longitude: -1.58103050228585e+2
  name: "Island Vintage Coffee"
  locality: "Hale'iwa"
---
""")
                                    .multilineTextAlignment(.leading)
                                }
                                .textSelection(.enabled)
                                .monospaced()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                            } footer: {
                                Text("Thoughts never collects or stores your data. See our [Privacy Policy](https://thoughts.jbmorley.co.uk/#privacy-policy).")
                            }
                        } actions: {
                            Button("Skip") {
                                withAnimation {
                                    self.page = .open
                                }
                            }
                            .keyboardShortcut(.cancelAction)
                            Button("Allow Location Access") {
                                withAnimation {
                                    introductionModel.hasLocatonAccess = true
                                    self.page = .open
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                        }
                    case .open:
                        AnyPage {
                            MarketingView(title: "Always Available", systemImage: "menubar.arrow.up.rectangle") {
                                Text("Thoughts lives in the menu bar, waiting for your notes.")
                                Text("Open at login to ensure you never miss something.")
                                MenuBarMockup()
                            }
                        } actions: {
                            Button("Skip") {
                                withAnimation {
                                    self.page = .keyboard
                                }
                            }
                            .keyboardShortcut(.cancelAction)
                            Button("Open at Login") {
                                withAnimation {
                                    self.page = .keyboard
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                        }
                    case .keyboard:
                        AnyPage {
                            MarketingView(title: "Keyboard First") {
                                Text("Use global shortcuts to write and edit notes without taking your hands off the keyboard.")
                                KeyboardShortcutPreview()
                            } header: {
                                Image(systemName: "keyboard")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 72, height: 72)
                                    .foregroundStyle(.tint)
                            }
                        } actions: {
                            Button("Start Writing") {
                                withAnimation {
                                    closeWindow()
                                    applicationModel.new()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }

}
