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

import Combine
import HighlightedTextEditor
import TagField

struct ComposeView: View {

    enum Focus {
        case text
        case tags
    }

    @FocusState var focus: Focus?

    var applicationModel: ApplicationModel

    init(applicationModel: ApplicationModel) {
        self.applicationModel = applicationModel
    }

    @MainActor var subtitle: String {
        var components: [String] = [
            applicationModel.document.date.formatted(date: .omitted, time: .standard)
        ]
        if let locationSummary = applicationModel.document.location?.summary {
            components.append(locationSummary)
        }
        return components.joined(separator: ", ")
    }

    var body: some View {
        @Bindable var applicationModel = applicationModel
        VStack(spacing: 0) {
            HighlightedTextEditor(text: $applicationModel.document.content, highlightRules: .markdown)
                .frame(minWidth: 400)
                .edgesIgnoringSafeArea(.all)
                .focused($focus, equals: .text)
            Divider()
            TagField("Add tags...", tokens: $applicationModel.document.tags) { candidate, tags in
                let currentTags = Set(tags)
                return applicationModel.tags
                    .words(prefix: candidate)
                    .filter { !currentTags.contains($0) }
            }
            .focused($focus, equals: .tags)
            .padding()
        }
        .onReceive(applicationModel.toggleFocusPublisher) { _ in
            focus = focus == .tags ? .text : .tags
        }
        .onAppear {
            // Unfortunately the `defaultFocus` modifier doesn't work out of the box with `NSViewRepresentable` views
            // so we fall back on the old tchnique of dispatching async to set the initial focus.
            DispatchQueue.main.async {
                focus = .text
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .navigationTitle(applicationModel.document.date.formatted(date: .complete, time: .standard))
        .navigationSubtitle(applicationModel.document.location?.summary ?? "")
        .toolbar {
            if applicationModel.shouldSaveLocation && applicationModel.document.location == nil {
                ToolbarItem(placement: .navigation) {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .onOpenURL { url in
            switch url {
            case .compose:
                // Reset the default focus on a new compose.
                focus = .text
            default:
                return
            }
        }
    }

}
