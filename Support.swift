//
//  Support.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/26/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

public struct Support {
    static func characterToUnicodeValue(_ c: Character)->Int {
        let s = String(c)
        return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
    }
    
    static func unicodeValueToCharacter(_ n: Int)->Character {
        return Character(UnicodeScalar(n)!)
    }
    
    static func splitStringIntoParts(_ expression: String)-> [String] {
        return expression.characters.split{$0 == " "}.map{ String($0) }
    }
    
    static func splitStringIntoLines(_ expression: String)-> [String] {
        return expression.characters.split{$0 == "\n"}.map{ String($0) }
    }
    
    static func readTextFile(_ path: String)-> (message: String?, fileText: String?) {
        let text: String
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        }
        catch {
            return ("\(error)", nil)
        }
        return (nil, text)
    }
    
    static func writeTextFile(_ path: String, data: String)-> String {
        let url = NSURL.fileURL(withPath: path)
        do {
            try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            return "Failed writing to URL: \(url), Error: " + error.localizedDescription
        }
        return "Writing to URL \(url) successful"
    }
    
    //returns a String with toBuffer on the left
    //and spaces on the right until length is matched
    static func buffer(_ toBuffer: String, _ length: Int)-> String {
        var endSpaces = ""
        for _ in 1...length - toBuffer.count {
            endSpaces += " "
        }
        return toBuffer + endSpaces
    }
    static func removeColon(_ labelDef: String)-> String {
        return String(labelDef.dropLast(1))
    }
}





