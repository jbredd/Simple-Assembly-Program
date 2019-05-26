//
//  Line.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 5/7/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation


struct Line: CustomStringConvertible {
    var lineText: String
    var chunks = [String]()
    var tokens = [Token]()
    var number: Int
    
    init(_ number: Int, _ line: String) {
        lineText = line
        self.number = number
        chunkinize(Array(line))
        tokens = Tokenizer.tokenizeChunks(chunks)
    }
    
    mutating func chunkinize(_ characters: [Character]) {
        var ignoreSpaces = false
        var chunk = ""
        for i in 0..<characters.count {
            if !ignoreSpaces {
                if characters[i] == " " || characters[i] == "\t" {
                    chunks.append(chunk)
                    chunk = ""
                } else {
                    chunk += String(characters[i])
                    if characters[i] == "\"" || characters[i] == "\\" {ignoreSpaces = true}
                    if i == characters.count - 1 {chunks.append(chunk)}
                }
            } else {
                chunk += String(characters[i])
                if characters[i] == "\"" || characters[i] == "\\" {
                    ignoreSpaces = false
                }
                if i == characters.count - 1 {chunks.append(chunk)}
            }
        }
        var cChunks = charChunks()
        if cChunks.count > 0{
            for i in 0..<cChunks.count{
                if cChunks[i].contains(";") {
                    chunks.removeSubrange(i..<cChunks.count)
                }
            }
        }
        chunks = chunks.filter{$0.count > 0}
    }
    func charChunks()->[[Character]]{
        var chChunks = [[Character]]()
        for c in chunks{
            chChunks.append(Array(c))
        }
        return chChunks
    }
    
    var description: String {
        return lineText
    }
}





