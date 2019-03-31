//
//  Support.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/26/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
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
}


