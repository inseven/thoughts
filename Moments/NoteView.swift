//
//  NoteView.swift
//  Moments
//
//  Created by Jason Barrie Morley on 23/01/2024.
//

import SwiftUI

struct NoteView: View {

    let url: URL

    @StateObject var note: Note

    init(url: URL) {
        self.url = url
        _note = StateObject(wrappedValue: Note(url: url))
    }

    var body: some View {
        HStack {
            TextEditor(text: $note.content)
                .scrollContentBackground(.hidden)
                .frame(minWidth: 400)
                .font(.system(size: 14, design: .monospaced))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .onAppear {
            note.start()
        }
        .onDisappear {
            note.stop()
        }
    }

}
