//
//  Note.swift
//  Moments
//
//  Created by Jason Barrie Morley on 23/01/2024.
//

import Combine
import SwiftUI

class Note: ObservableObject {

    let url: URL

    @Published var content: String = ""

    private var cancellables: Set<AnyCancellable> = []

    init(url: URL) {
        self.url = url
    }

    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        $content
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { content in
                // TODO: Report the error.
                try! content.write(to: self.url, atomically: true, encoding: .utf8)
            }
            .store(in: &cancellables)

        // Load the content before starting.
        if FileManager.default.fileExists(atPath: url.path) {
            content = try! String(contentsOf: url)
        }
    }

    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        cancellables.removeAll()
    }

}
