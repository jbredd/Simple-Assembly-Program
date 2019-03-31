//
//  StatusFlag.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/30/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation



struct StatusFlag {
    var status = 0
    
    //-1 corresponds to < ; 0 corresponds to = ; 1 corresponds to 1
    mutating func makeLessThan() {status = -1}
    mutating func makeEqual() {status = 0}
    mutating func makeMoreThan() {status = 1}
}





