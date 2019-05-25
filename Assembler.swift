//
//  Assembler.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 5/19/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

struct Assembler{
    var program: Program? = nil
    
    var instructionArgs: [String: [TokenType]] = [:]
    var directiveArgs: [String : [TokenType]] = [:]
    let support = Support()
    var userInput = ""
    init() {fillDictionary()}
    
    
    mutating func read()-> Bool {
        if support.readTextFile(program!.path).fileText == nil {
            print(support.readTextFile(program!.path).message!)
            return false
        }
        let fileContent = support.readTextFile(program!.path).fileText!
        let inputCode = support.splitStringIntoLines(fileContent)
        for i in 0..<inputCode.count {
            //print("\(i + 1)     \(inputCode[i])")
            if inputCode[i].count > 0 {
                program!.lines.append(Line(i + 1, inputCode[i]))
            }
        }
        return true
    }
    
    
    mutating func assemble(_ path: String) {
        program = Program(path)
        passOne()
        if !program!.legal {print("...Assembly was unsuccessful"); return}
        passTwo()
        print("...Assembly was successful")
    }
    
    mutating func fillDictionary() {
        directiveArgs[".start"] = [.Label]
        directiveArgs[".string"] = [.ImmediateString]
        directiveArgs[".integer"] = [.ImmediateInteger]
        directiveArgs[".tuple"] = [.ImmediateTuple]
        instructionArgs["halt"] = []
        instructionArgs["clrr"] = [.Register]
        instructionArgs["clrx"] = [.Register]
        instructionArgs["clrm"] = [.Label]
        instructionArgs["clrb"] = [.Register, .Register]
        instructionArgs["movir"] = [.ImmediateInteger, .Register]
        instructionArgs["movrr"] = [.Register, .Register]
        instructionArgs["movrm"] = [.Register, .Label]
        instructionArgs["movmr"] = [.Label, .Register]
        instructionArgs["movxr"] = [.Register, .Register]
        instructionArgs["movar"] = [.Label, .Register]
        instructionArgs["movb"] = [.Register, .Register, .Register]
        instructionArgs["addir"] = [.ImmediateInteger, .Register]
        instructionArgs["addrr"] = [.Register, .Register]
        instructionArgs["addmr"] = [.Label, .Register]
        instructionArgs["addxr"] = [.Register, .Register]
        instructionArgs["subir"] = [.ImmediateInteger, .Register]
        instructionArgs["subrr"] = [.Register, .Register]
        instructionArgs["submr"] = [.Label, .Register]
        instructionArgs["subxr"] = [.Register, .Register]
        instructionArgs["mulir"] = [.ImmediateInteger, .Register]
        instructionArgs["mulrr"] = [.Register, .Register]
        instructionArgs["mulmr"] = [.Label, .Register]
        instructionArgs["mulxr"] = [.Register, .Register]
        instructionArgs["divir"] = [.ImmediateInteger, .Register]
        instructionArgs["divrr"] = [.Register, .Register]
        instructionArgs["divmr"] = [.Label, .Register]
        instructionArgs["divxr"] = [.Register, .Register]
        instructionArgs["jmp"] = [.Label]
        instructionArgs["sojz"] = [.Register, .Label]
        instructionArgs["sojnz"] = [.Register, .Label]
        instructionArgs["aojz"] = [.Register, .Label]
        instructionArgs["aojnz"] = [.Register, .Label]
        instructionArgs["cmpir"] = [.ImmediateInteger, .Register]
        instructionArgs["cmprr"] = [.Register, .Register]
        instructionArgs["cmpmr"] = [.Label, .Register]
        instructionArgs["jmpn"] = [.Label]
        instructionArgs["jmpz"] = [.Label]
        instructionArgs["jmpp"] = [.Label]
        instructionArgs["jsr"] = [.Label]
        instructionArgs["ret"] = []
        instructionArgs["push"] = [.Register]
        instructionArgs["pop"] = [.Register]
        instructionArgs["stackc"] = [.Register]
        instructionArgs["outci"] = [.ImmediateInteger]
        instructionArgs["outcr"] = [.Register]
        instructionArgs["outcx"] = [.Register]
        instructionArgs["outcb"] = [.Register, .Register]
        instructionArgs["readi"] = [.Register, .Register]
        instructionArgs["printi"] = [.Register]
        instructionArgs["readc"] = [.Register]
        instructionArgs["readln"] = [.Label, .Register]
        instructionArgs["brk"] = []
        instructionArgs["movrx"] = [.Register, .Register]
        instructionArgs["movxx"] = [.Register, .Register]
        instructionArgs["outs"] = [.Label]
        instructionArgs["nop"] = []
        instructionArgs["jmpne"] = [.Label]
    }
    
    func printSymVal() {
        if program == nil {print("Please assemble a program first"); return}
        print("Symbol table: \n")
        for (k, _) in program!.symVal {
            print("\(support.buffer(removeColon(k), 22)) \(program!.symVal[k]!)")
        }
    }
    func removeColon(_ labelDef: String)-> String {
        return String(labelDef.dropLast(1))
    }
}

// PASS ONE
extension Assembler{
    //passOne makes symVal and checks for legality
    mutating func passOne() {
        if !read() {return}
        program!.legal = true
        makeSymVal(program!.lines)
        for l in program!.lines {
            print(l, terminator: "")
            if !isLegal(l).0 {program!.legal = false}
            print(isLegal(l).1)
        }
    }
    
    mutating func makeSymVal(_ lines: [Line]) { //WRONG
        var memLocation = -1 //to account for .start label not taking up a space
        for l in lines {
            for i in 0..<l.tokens.count {
                switch l.tokens[i].type {
                case .LabelDefinition: program!.symVal[l.chunks[i]] = memLocation
                case .ImmediateInteger: memLocation += 1
                case .ImmediateString: memLocation += l.chunks[i].count - 1
                case .ImmediateTuple: memLocation += 5
                case .Label: memLocation += 1
                case .Instruction: memLocation += 1
                case .Register: memLocation += 1
                default: memLocation += 0 //executed if .Directive or .BadToken, in which case no memory locations modified
                }
            }
        }
    }
    
    // returns (args are legal, error message)
    func isLegal(_ line: Line)-> (Bool, String) {
        let chunks = line.chunks
        let tokens = line.tokens
        if tokens.count >= 1 {
            switch tokens[0].type {
            case .Instruction: return validInstructionArgs(line, 0)
            case .Directive: return validDirectiveArg(line, 0)
            case .LabelDefinition:
                if tokens[1].type == .Instruction {return validInstructionArgs(line, 1)}
                if tokens[1].type == .Directive {return validDirectiveArg(line, 1)}
                return (false, "\n..........A Label Definition must be followed by an Instruction or a Directive")
            case .BadToken: return (false, "\n..........\(chunks[0]) is a Bad Token")
            default: return (false, "\n..........Line must start with an Instruction, .Start, or a Label Definition")
            }
        } else {return (true, "")} //to account for comment/blank lines
    }
    
    //(args are legal, error message), the start arg is the index of the instruction token
    func validInstructionArgs(_ line: Line, _ start: Int)-> (Bool, String) {
        let expected = instructionArgs[line.chunks[start]]
        if expected != nil{
            if line.tokens.count - start > expected!.count + 1 {return (false, "\n..........\(line.chunks[start]) has too many arguments")}
            for i in 0..<expected!.count {
                if expected![i] == .Label && !labelExists(line.chunks[i + start + 1]) {return (false, "\n..........Label \"\(line.chunks[start + i + 1])\" has not been defined")}
                if line.tokens[start + i + 1].type != expected![i] {
                    return (false, "\n..........Instruction \(line.chunks[start]) arguments are not as expected")
                }
            }
            return (true, "")
        }
        return (false, "")
    }
    
    //(args are legal, error message), the start arg is the index of the directive token
    func validDirectiveArg(_ line: Line, _ start: Int)-> (Bool, String) {
        let expected = directiveArgs[line.chunks[start]]
        if line.tokens.count - start != 2 {return (false, "\n..........Directives should take in one argument")}
        if line.tokens[start + 1].type == expected![0] {return (true, "")}
        return (false, "\n..........\(line.chunks[start]) should take in an \(expected![0])")
    }
    
    func labelExists(_ label: String)-> Bool {
        return program!.symVal[label + ":"] != nil
    }
}

// PASS TWO
extension Assembler {
    // pass two makes translates assembly to binary
    mutating func passTwo() {
        if !program!.legal {return}
        translate()
    }
    
    func printBin() {
        if program == nil {print("Please assemble a program first"); return}
        print(program!.length)
        print(program!.start)
        for i in 0..<program!.mem.count {print("\(program!.mem[i])")}
        print("\n\n\n")
    }
    
    mutating func translate() {
        program!.mem = [Int]()
        for l in program!.lines {
            for i in 0..<l.tokens.count {
                switch l.tokens[i].type {
                case .Register: program!.mem.append(Translator.registers[l.chunks[i]]!)
                case .ImmediateString: for b in translateString(l.tokens[i].stringValue!) {program!.mem.append(b)}
                case .ImmediateInteger: program!.mem.append(l.tokens[i].intValue!)
                case .ImmediateTuple: for b in translateTuple(l.tokens[i]) {program!.mem.append(b)}
                case .Instruction: program!.mem.append(Translator.instructions[l.chunks[i]]!)
                case .Label: program!.mem.append(program!.symVal[l.chunks[i] + ":"]!)
                case .Directive: print("", terminator: "") //does nothing
                case .LabelDefinition: print("", terminator: "") //does nothing
                default: print("this should never be printed as pass one should vet for legality")
                }
            }
        }
        //.start location already at beginning due to label locations
        //being put into memory whenever they are encountered
        program!.start = program!.mem[0]
        program!.length = program!.mem.count - 1
        program!.mem.remove(at: 0)
    }
    // \0 _ 0 _ r\
    mutating func translateTuple(_ token: Token)->[Int] {
        var binary = [Int]()
        binary.append(token.tupleValue!.currentState) //should be cs
        binary.append(support.characterToUnicodeValue(token.tupleValue!.inputCharacter)) //should be ic
        binary.append(token.tupleValue!.newState) //should be ns
        binary.append(support.characterToUnicodeValue(token.tupleValue!.outputCharacter)) //should be oc
        binary.append(token.tupleValue!.direction) //should be di
        return binary
    }
    
    mutating func translateString(_ string: String)->[Int] {
        var binary = [Int]()
        let stringChars = Array(string)
        binary.append(stringChars.count)
        for c in stringChars {
            binary.append(support.characterToUnicodeValue(c))
        }
        return binary
    }
    
    func getIgnore(_ tokens: [Token])-> Int {
        var toIgnore = 0
        for t in tokens {
            if t.type == .LabelDefinition || t.type == .Directive {
                toIgnore += 1
            }
        }
        return toIgnore
    }
    
    func getMemContents(_ address: Int, _ l: Line)-> String {
        var memContents = ""
        if address >= program!.length {return "\n"}
        for n in 0..<l.tokens.count {
            switch l.tokens[n].type {
            case .ImmediateString:
                for i in 0..<program!.mem[address] {
                    if i <= 3 {
                        memContents += " \(program!.mem[address + i])"
                    }
                }
            case .ImmediateTuple:
                for i in 0..<4 {
                    memContents += " \(program!.mem[address + i])"
                }
            case .ImmediateInteger:
                memContents += " \(program!.mem[address + n - getIgnore(l.tokens)])"
            case .Label:
                if l.chunks[0] != ".start" {
                    memContents += " \(program!.mem[address + n - getIgnore(l.tokens)])"
                }
            case .Instruction:
                memContents += " \(program!.mem[address + n - getIgnore(l.tokens)])"
            case .Register:
                memContents += " \(program!.mem[address + n - getIgnore(l.tokens)])"
            default: print("", terminator: "")
            }
        }
        return "\(memContents)"
    }
    
    func printLst() {
        if program == nil {print("Please assemble a program first"); return}
        var toPrint = ""
        var memLocation = 0
        var memContents = " "
        for l in program!.lines {
            //must getMemContents before changing memLocation since memLocation when printed
            memContents = getMemContents(memLocation, l)
            toPrint += support.buffer("\(memLocation): \(memContents)", 23) + l.lineText + "\n"
            for i in 0..<l.tokens.count {
                switch l.tokens[i].type {
                case .ImmediateString: memLocation += l.chunks[i].count - 1
                case .ImmediateTuple: memLocation += 5
                case .ImmediateInteger: memLocation += 1
                case .Label:
                    if l.chunks[i - 1] != ".start" {memLocation += 1}
                case .Instruction: memLocation += 1
                case .Register: memLocation += 1
                default: memLocation += 0
                }
            }
        }
        print(toPrint)
    }
}

