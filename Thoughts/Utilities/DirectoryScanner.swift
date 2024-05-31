// MIT License
//
// Copyright (c) 2023-2024 Jason Morley
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

import FSEventsWrapper

protocol DirectoryScannerDelegate: NSObject {

    func directoryScannerDidStart(_ directoryScanner: DirectoryScanner)

}

// TODO: Start/stop thread-safety
// TODO: Perhaps we could require that this is started and stopped on its workQueue? That might make it easiest to manage
// TODO: Allow us to add a target queue?
class DirectoryScanner {

    let url: URL
    let workQueue = DispatchQueue(label: "workQueue")
    var stream: FSEventStream? = nil
    var identifiers = [Details.Identifier: Details]()  // Synchronized on workQueue
    weak var delegate: DirectoryScannerDelegate?

    init(url: URL) {
        self.url = url
    }

    func start(load: @escaping () -> Set<Details>,
               onFileCreation: @escaping (any Collection<Details>) -> Void,
               onFileUpdate: @escaping (any Collection<Details>) -> Void,
               onFileDeletion: @escaping (any Collection<Details.Identifier>) -> Void) {
        // TODO: Allow this to be run with a blocking startup.
        dispatchPrecondition(condition: .notOnQueue(workQueue))

        let ownerURL = url

        // TODO: Consider creating this in the constructor.
        stream = FSEventStream(path: url.path,
                               fsEventStreamFlags: FSEventStreamEventFlags(kFSEventStreamCreateFlagFileEvents),
                               queue: workQueue) { [weak self] stream, event in
            guard let self else {
                return
            }

            let fileManager = FileManager.default

            do {
                switch event {
                case .itemClonedAtPath:
                    return
                case .itemCreated(path: let path, itemType: let itemType, eventId: _, fromUs: _):

                    let url = URL(filePath: path, itemType: itemType)
                    let details = try fileManager.details(for: url, owner: ownerURL)

                    // Depending on the system load, it seems like we sometimes receive events for file operations that
                    // were already captured in our initial snapshot that we want to ignore.
                    guard self.identifiers[details.identifier] == nil else {
                        return
                    }

                    onFileCreation([details])
                    self.identifiers[details.identifier] = details

                case .itemRenamed(path: let path, itemType: let itemType, eventId: _, fromUs: _):

                    // Helpfully, file renames can be additions or removals, so we check to see if the file exists at the
                    // new location to determine which.
                    let url = URL(filePath: path, itemType: itemType)
                    if fileManager.fileExists(atPath: url.path) {

                        let details = try fileManager.details(for: url, owner: ownerURL)

                        // If a file exists at the new path and also exists in our runtime cache of files then we infer
                        // that this rename actuall represents a content modification operation; our file has been
                        // atomically replaced by a new file containing new content.
                        if let old = self.identifiers[details.identifier] {
                            let update = old.applying(details: details)
                            self.identifiers[details.identifier] = update
                            onFileUpdate([update])
                            return
                            // TODO: We should ensure we delete all our children if we're a directory.
                        }

                        // We don't get notified about files contained within a directory, so we walk those explicitly.
                        if itemType == .dir {
                            let files = try fileManager.files(directoryURL: url, ownerURL: ownerURL)
                            onFileCreation(files)
                            for file in files {
                                self.identifiers[file.identifier] = file
                            }
                        } else {
                            onFileCreation([details])
                            self.identifiers[details.identifier] = details
                        }

                    } else {
                        // If it's a directory, then we need to work out what files are being removed.
                        let identifier = Details.Identifier(ownerURL: ownerURL, url: url)
                        if itemType == .dir {
                            let identifiers = self.identifiers.keys.filter { $0.url.path.hasPrefix(url.path + "/") } + [identifier]
                            onFileDeletion(Array(identifiers))
                            for identifier in identifiers {
                                self.identifiers.removeValue(forKey: identifier)
                            }
                        } else {
                            onFileDeletion([identifier])
                            self.identifiers.removeValue(forKey: identifier)
                        }
                    }

                case .itemRemoved(path: let path, itemType: let itemType, eventId: _, fromUs: _):

                    let url = URL(filePath: path, itemType: itemType)
                    let identifier = Details.Identifier(ownerURL: ownerURL, url: url)
                    onFileDeletion([identifier])
                    self.identifiers.removeValue(forKey: identifier)

                case .itemInodeMetadataModified(path: let path, itemType: let itemType, eventId: _, fromUs: _),
                     .itemDataModified(path: let path, itemType: let itemType, eventId: _, fromUs: _):

                    // TODO: We need to handle directories carefully here.

                    // TODO: Consider generalising this code.
                    let url = URL(filePath: path, itemType: itemType)
                    let identifier = Details.Identifier(ownerURL: ownerURL, url: url)
                    let details = try fileManager.details(for: url, owner: ownerURL)

                    // Remove the file if it exists in our set.
                    if let old = self.identifiers[identifier] {
                        let new = old.applying(details: details)
                        onFileUpdate([new])
                        self.identifiers[identifier] = new
                        return
                    }

                    // Create a new identifier corresponding to the udpated file.
                    onFileCreation([details])
                    self.identifiers[identifier] = details

                case .itemOwnershipModified, .itemXattrModified:
                    return

                default:
                    print("Unhandled file event \(event).")
                }

            } catch {
                print("Failed to handle update with error \(error).")
            }
        }

        guard let stream else {
            preconditionFailure("Failed to create event stream!")
        }

        workQueue.async { [weak self, url] in
            guard let self else {
                return
            }

            // Start the event stream watching.
            // We do this from here to ensure we don't miss any events, and that all individual change callbacks are
            // enqueued after our initial scan.
            stream.startWatching()

            // TODO: Handle errors.
            let fileManager = FileManager.default

            // TODO: Index by URL not Identifier

            // Load the snapshot.
            let snapshot = load()
            // TODO: Rename
            let snapshotIdentifiers = snapshot.reduce(into: [Details.Identifier: Details]()) { partialResult, details in
                partialResult[details.identifier] = details
            }

            // Load the current state from the file system.
            let current = Set(try! fileManager.files(directoryURL: url))
            let currentIdentifiers = current.reduce(into: [Details.Identifier: Details]()) { partialResult, details in
                partialResult[details.identifier] = details
            }

            // Determine the deleted files and apply the changes.
            let deletedIdentifiers = Set(snapshotIdentifiers.keys).subtracting(currentIdentifiers.keys)
            if deletedIdentifiers.count > 0 {
                onFileDeletion(deletedIdentifiers)
            }

            // Walk the current files, determine the operation required to update the snapshot, and assemble the
            // in-memory state.
            var additions = [Details]()
            var updates = [Details]()
            var state = [Details.Identifier: Details]()

            // TODO: Can and should we track deletions here too?
            for file in current {
                if let snapshot = snapshotIdentifiers[file.identifier] {
                    if !snapshot.equivalent(to: file) {  // Modified.
                        let update = snapshot.applying(details: file)
                        updates.append(update)
                        state[file.identifier] = update
                    } else {  // Unchanged.
                        state[file.identifier] = snapshot
                    }
                } else {  // Created.
                    additions.append(file)
                    state[file.identifier] = file
                }
            }

            // Add the new files.
            if additions.count > 0 {
                onFileCreation(additions)
            }

            // Apply the updates.
            if updates.count > 0 {
                onFileUpdate(updates)
            }

            // Cache the initial state.
            self.identifiers = state
            self.delegate?.directoryScannerDidStart(self)
        }

    }

    func stop() {
        // TODO: Do this on the workQueue to ensure it's all thread-safe and we guarantee we don't get any more callbacks?
        stream?.stopWatching()
        stream = nil
    }

}

