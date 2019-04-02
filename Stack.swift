//
//  Stack.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 4/1/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

struct Stack<Element>: CustomStringConvertible {
    var stack: [Element?]
    var pushIndex = 0
    init(size: Int) {
        stack = Array(repeating: nil, count: size)
    }
    
    func isEmpty()->Bool {
        return pushIndex == 0
    }
    func isFull()->Bool {
        return pushIndex == stack.count
    }
    
    mutating func push(_ element: Element) {
        if self.isFull() {
            print("Cannot push \(element), stack is full")
            return
        }
        stack[pushIndex] = Optional(element)
        pushIndex += 1
    }
    mutating func pop()-> Element? {
        var result: Element? = nil
        if self.isEmpty() {
            print("cannot pop, stack is empty")
            return result
        }
        result = stack[pushIndex - 1]
        pushIndex = pushIndex - 1
        return result
    }
    
    var description: String {
        var result = "Stack in order of first pushed to last: "
        for i in 0 ..< pushIndex {
            result += "\(stack[i]!) "
        }
        return result
    }
    func map<U>(_ f: (Element)-> U)-> Stack<U> {
        var result = Stack<U>(size: 0)
        result.pushIndex = pushIndex
        for s in stack {
            result.stack.append(f(s!))
        }
        return result
    }
}






