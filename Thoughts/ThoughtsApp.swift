//
//  Disk_StickiesApp.swift
//  Disk Stickies
//
//  Created by Jason Barrie Morley on 23/01/2024.
//

import SwiftUI

@main
struct ThoughtsApp: App {

    var applicationModel = ApplicationModel()

    var body: some Scene {

        MenuBarExtra {
            Items(applicationModel: applicationModel)
        } label: {
            Image(systemName: "note.text")
        }

        WindowGroup(id: "note", for: URL.self) { url in
            if let url = url.wrappedValue {
                NoteView(url: url)
            }
        }
        .defaultSize(width: 800, height: 600)

    }
}
