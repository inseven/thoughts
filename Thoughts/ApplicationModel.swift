//
//  ApplicationModel.swift
//  Moments
//
//  Created by Jason Barrie Morley on 23/01/2024.
//

import Foundation

class ApplicationModel: ObservableObject {

    static let folderURL = URL(fileURLWithPath: "/Users/jbmorley/Notes/Stream/")

    @Published var notes: [Note] = []

}
