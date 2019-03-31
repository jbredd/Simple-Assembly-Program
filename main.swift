//
//  main.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/26/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

var binary = [79, 43, 0, 20, 10, 26, 65, 32, 80, 114, 111, 103, 114, 97, 109, 32, 84]
binary += [111, 32, 80, 114, 105, 110, 116, 32, 68, 111, 117, 98, 108, 101, 115, 12, 32, 68, 111, 117]
binary += [98, 108, 101, 100, 32, 105, 115, 32, 8, 0, 8, 8, 1, 9, 8, 2, 0, 55, 3, 45, 0, 6, 8, 1, 13]
binary += [8, 1, 49, 8, 55, 30, 49, 1, 45, 0, 34, 8, 9, 12, 1, 8, 57, 56, 0]
//for n in binary {print(n)}
//print(binary.count - 2)


var vm = PartialVM(mem: binary)
vm.run()

