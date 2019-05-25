//
//  Program.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 5/24/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

public struct Program: CustomStringConvertible {
    var path: String
    var lines = [Line]()
    var legal = false
    var start = 0
    var length = 0
    var mem = [Int]()
    var registers = Array(repeating: 0, count: 10)
    var symVal: [String: Int] = [:]
    
    init(_ path: String) {
        self.path = path
    }
    
    
    public var description: String {
        return " "
    }
}





