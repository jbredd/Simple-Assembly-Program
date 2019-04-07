//
//  Support.swift
//  PartialVM
//
//  Created by Nicholas Hatzis-Schoch on 4/3/19.
//  Copyright © 2019 Slick Games. All rights reserved.
//

import Foundation

public struct Support {
    func characterToUnicodeValue(_ c: Character)->Int {
        let s = String(c)
        return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
    }
    
    func unicodeValueToCharacter(_ n: Int)->Character {
        return Character(UnicodeScalar(n)!)
    }
    
    func splitStringIntoParts(_ expression: String)-> [String] {
        return expression.characters.split{$0 == " "}.map{ String($0) }
    }
    
    func splitStringIntoLines(_ expression: String)-> [String] {
        return expression.characters.split{$0 == "\n"}.map{ String($0) }
    }
    
    func readTextFile(_ path: String)-> (message: String?, fileText: String?) {
        let text: String
        do {
            text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        }
        catch {
            return ("\(error)", nil)
        }
        return (nil, text)
    }
    
    func writeTextFile(_ path: String, data: String)-> String? {
        let url = NSURL.fileURL(withPath: path)
        do {
            try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            return "Failed writing to URL: \(url), Error: " + error.localizedDescription
        }
        return nil
    }
    
    func fitD(_ d: Date, _ size: Int, right: Bool = false)-> String {
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        let dAsString = df.string(from: d)
        return fit(dAsString, size, right: right)
    }
    
    func fitI(_ i: Int, _ size: Int, right: Bool = false)-> String {
        let iAsString = "\(i)"
        let newLength = iAsString.characters.count
        return fit(iAsString, newLength > size ? newLength: size, right: right)
    }
    
    func fit(_ s: String, _ size: Int, right: Bool = true)-> String {
        var result = ""
        let sSize = s.characters.count
        if sSize == size {return s}
        var count = 0
        if size < sSize {
            for c in s.characters {
                if count < size {result.append(c)}
                count += 1
            }
            return result
        }
        result = s
        var addon = ""
        let num = size - sSize
        for _ in 0..<num {addon.append(" ")}
        if right {return result + addon}
        return addon + result
    }
}
