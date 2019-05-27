//
//  Program.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 5/24/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

public struct Program {
    var path: String
    var lines = [Line]()
    var legal = false
    var start = 0
    var length = 0
    var mem = [Int]()
    var symVal: [String: Int] = [:]
    var valSym: [Int: String] = [:]
    
    init(_ path: String) {
        self.path = path
    }
}





