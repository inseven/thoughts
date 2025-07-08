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

import Foundation

class Trie {

    private class TrieNode {
        var children: [Character: TrieNode] = [:]
        var isEndOfWord: Bool = false
    }

    private var root: TrieNode

    init(words: any Collection<String> = []) {
        self.root = TrieNode()
        for word in words {
            insert(word)
        }
    }

    func insert(_ word: String) {
        var current = root
        for char in word {
            if current.children[char] == nil {
                current.children[char] = TrieNode()
            }
            current = current.children[char]!
        }
        current.isEndOfWord = true
    }

    func contains(_ word: String) -> Bool {
        var current = root
        for char in word {
            if let node = current.children[char] {
                current = node
            } else {
                return false
            }
        }
        return current.isEndOfWord
    }

    func words(prefix: String) -> [String] {
        var current = root
        for char in prefix {
            if let node = current.children[char] {
                current = node
            } else {
                return []
            }
        }
        return collectWords(node: current, prefix: prefix)
    }

    private func collectWords(node: TrieNode, prefix: String) -> [String] {
        var results: [String] = []
        if node.isEndOfWord {
            results.append(prefix)
        }
        for (char, childNode) in node.children {
            results.append(contentsOf: collectWords(node: childNode, prefix: prefix + String(char)))
        }
        return results
    }

}
