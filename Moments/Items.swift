//
//  Items.swift
//  Moments
//
//  Created by Jason Barrie Morley on 23/01/2024.
//

import SwiftUI

struct Items: View {

    @ObservedObject var applicationModel: ApplicationModel

    @Environment(\.openWindow) var openWindow

    var body: some View {
        Button("New Note...") {
            let formatter = ISO8601DateFormatter()
            // TODO: Format options?
            formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate]
            let date = formatter.string(from: Date())
            let url = ApplicationModel.folderURL.appendingPathComponent(date).appendingPathExtension("md")

            // Create the file if it doesn't exist.
            if !FileManager.default.fileExists(atPath: url.path) {
                let contents = "---\ndate: \(date)\ntags:\n---\n\n"
                try! contents.write(to: url, atomically: true, encoding: .utf8)
            }

            // Open the window.
            openWindow(id: "note", value: url)
        }
    }

}
