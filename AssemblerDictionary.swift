//
//  Translator.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 5/19/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation


struct AssemblerDictionary {
    static let registers = ["r0": 0, "r1": 1, "r2": 2, "r3": 3, "r4": 4, "r5": 5, "r6": 6, "r7": 7, "r8": 8, "r9": 9]
    static let instructions = ["halt": 0, "clrr": 1, "clrx": 2, "clrm": 3, "clrb": 4, "movir": 5, "movrr": 6, "movrm": 7, "movmr": 8, "movxr": 9, "movar": 10, "movb": 11, "addir": 12, "addrr": 13, "addmr": 14, "addxr": 15, "subir": 16, "subrr": 17, "submr": 18, "subxr": 19, "mulir": 20, "mulrr": 21, "mulmr": 22, "mulxr": 23, "divir": 24, "divrr": 25, "divmr": 26, "divxr": 27, "jmp": 28, "sojz": 29, "sojnz": 30, "aojz": 31, "aojnz": 32, "cmpir": 33, "cmprr": 34, "cmpmr": 35, "jmpn": 36, "jmpz": 37, "jmpp": 38, "jsr": 39, "ret": 40, "push": 41, "pop": 42, "stackc": 43, "outci": 44, "outcr": 45, "outcx": 46, "outcb": 47, "readi": 48, "printi": 49, "readc": 50, "readln": 51, "brk": 52, "movrx": 53, "movxx": 54, "outs": 55, "nop": 56, "jmpne": 57]
    static let instructionCodes = [0: "halt", 1: "clrr", 2: "clrx", 3: "clrm", 4: "clrb", 5: "movir", 6: "movrr", 7: "movrm", 8: "movmr", 9: "movxr", 10: "movar", 11: "movb", 12: "addir", 13: "addrr", 14: "addmr", 15: "addxr", 16: "subir", 17: "subrr", 18: "submr", 19: "subxr", 20: "mulir", 21: "mulrr", 22: "mulmr", 23: "mulxr", 24: "divir", 25: "divrr", 26: "divmr", 27: "divxr", 28: "jmp", 29: "sojz", 30: "sojnz", 31: "aojz", 32: "aojnz", 33: "cmpir", 34: "cmprr", 35: "cmpmr", 36: "jmpn", 37: "jmpz", 38: "jmpp", 39: "jsr", 40: "ret", 41: "push", 42: "pop", 43: "stackc", 44: "outci", 45: "outcr", 46: "outcx", 47: "outcb", 48: "readi", 49: "printi", 50: "readc", 51: "readln", 52: "brk", 53: "movrx", 54: "movxx", 55: "outs", 56: "nop", 57: "jmpne"]
    static let instructionArgs: [String: [TokenType]] = ["halt": [], "clrr": [.Register], "clrx": [.Register], "clrm": [.Label], "clrb": [.Register, .Register], "movir": [.ImmediateInteger, .Register], "movrr": [.Register, .Register], "movrm": [.Register, .Label], "movmr": [.Label, .Register], "movxr": [.Register, .Register], "movar": [.Label, .Register], "movb": [.Register, .Register, .Register], "addir": [.ImmediateInteger, .Register], "addrr": [.Register, .Register], "addmr": [.Label, .Register], "addxr": [.Register, .Register], "subir": [.ImmediateInteger, .Register], "subrr": [.Register, .Register], "submr": [.Label, .Register], "subxr": [.Register, .Register], "mulir": [.ImmediateInteger, .Register], "mulrr": [.Register, .Register], "mulmr": [.Label, .Register], "mulxr": [.Register, .Register], "divir": [.ImmediateInteger, .Register], "divrr": [.Register, .Register], "divmr": [.Label, .Register], "divxr": [.Register, .Register], "jmp": [.Label], "sojz": [.Register, .Label], "sojnz": [.Register, .Label], "aojz": [.Register, .Label], "aonjz": [.Register, .Label], "cmpir": [.ImmediateInteger, .Register], "cmprr": [.Register, .Register], "cmpmr": [.Label, .Register], "jmpn": [.Label], "jmpz": [.Label], "jmpp": [.Label], "jsr": [.Label], "ret": [], "push": [.Register], "pop": [.Register], "stackc": [.Register], "outci": [.ImmediateInteger], "outcr": [.Register], "outcx": [.Register], "outcb": [.Register, .Register], "readi": [.Register, .Register], "printi": [.Register], "readc": [.Register], "readln": [.Label, .Register], "brk": [], "movrx": [.Register, .Register], "movxx": [.Register, .Register], "outs": [.Label], "nop": [], "jmpne": [.Label]]
    static let directiveArgs: [String: [TokenType]] = [".start": [.Label], ".string": [.ImmediateString], ".integer": [.ImmediateInteger], ".tuple": [.ImmediateTuple], ".Start": [.Label], ".String": [.ImmediateString], ".Integer": [.ImmediateInteger], ".Tuple": [.ImmediateTuple]]
}





