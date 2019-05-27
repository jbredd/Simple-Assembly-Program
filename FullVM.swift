//
//  FullVM.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/26/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//
import Foundation


struct FullVM {
    var instructionPointer = 0
    var registers = Array(repeating: 0, count: 10)
    var statusFlag = StatusFlag()
    var breakPoints = [Int]()
    var brksDisabled = false
    
    var stack = Stack<Int>(size: 200)
    var userInput = ""
    var wasCrashed = false
    var asmblr = Assembler()
    var pathSpecs = ""
    
    var stackRegister: Int {
        if stack.isEmpty() {return 2}
        if stack.isFull() {return 1}
        return 0
    }
    var console: String = ""
    var retTo = [Int]()
    

    init() {}
    
    mutating func run() {
        print("Welcome to SAP!")
        help()
        print("\n> ", terminator: "")
        userInput = readLine()!
        while userInput != "quit" {
            var splitInput = Support.splitStringIntoParts(userInput)
            if splitInput.count > 0 {
                switch splitInput[0] {
                //for each case the number of arguments is checked first
                case "asm":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("asm", 1, numArgs(splitInput))); break}
                    asmblr.assemble(pathSpecs, splitInput[1])
                case "run":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("run", 1, numArgs(splitInput))); break}
                    runDebugger(pathSpecs + splitInput[1] + ".txt")
                    if wasCrashed {print("\n...Binary execution unsuccessful")}
                    else {print("\n...Binary execution successful")}
                case "path":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("path", 1, numArgs(splitInput))); break}
                    pathSpecs = splitInput[1]
                case "printlst":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("printlst", 1, numArgs(splitInput))); break}
                    asmblr.printLst(pathSpecs + splitInput[1] + ".txt")
                case "printbin":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("printbin", 1, numArgs(splitInput))); break}
                    asmblr.printBin(pathSpecs + splitInput[1] + ".txt")
                case "printsym":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("printsym", 1, numArgs(splitInput))); break}
                    asmblr.printSymVal(pathSpecs + splitInput[1] + ".txt")
                case "help":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("help", 0, numArgs(splitInput))); break}
                    help()
                default: print("'\(splitInput[0])' is an invalid command. Please type again carefully\n")
                }
            }
            print("\n> ", terminator: "")
            userInput = readLine()!
        }
        print("...SAP exited")
        return
    }
    
    func wrongNumArgsMessage(_ commandName: String, _ expectedNum: Int, _ numArgs: Int)-> String {
        return "The command \"\(commandName)\" takes in \(expectedNum) arguments, you put in \(numArgs). Please type again carefully"
    }
    
    func getPIndex(_ path: String)-> Int? {
        return asmblr.getProgramIndex(path)
    }
}

//DEBUGGER EXTENSION
extension FullVM {
    mutating func runDebugger(_ path: String) {
        let pIndex = getPIndex(path)
        if pIndex == nil {
            print("Please assemble program \"\(path)\" first")
            wasCrashed = true; return
        }
        let p = asmblr.programs[pIndex!]
        let ogMem = p.mem //to ensure that consecutive runs of the same program do not use different memory but the original memory
        //reset registers, sflag, pc, bkpnts, disabled so that they are not carried over from last run
        registers = Array(repeating: 0, count: 10)
        statusFlag = StatusFlag()
        instructionPointer = p.start
        breakPoints = [Int]()
        brksDisabled = false
        
        
        debuggerHelp()
        print("Sdb (\(instructionPointer), \(p.mem[instructionPointer]))> ", terminator: "")
        userInput = readLine()!
        while userInput != "exit" {
            var splitInput = Support.splitStringIntoParts(userInput)
            if splitInput.count > 0 {
                switch splitInput[0] {
                    //for each case first num args is checked then if types match expected
                case "setbk":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("setbk", 1, numArgs(splitInput))); break}
                    let bk = Int(splitInput[1])
                    if bk != nil {setbk(path, bk!)}
                    else {print("The commmand \"setbk\" should take in an integer")}
                case "rmbk":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("rmbk", 1, numArgs(splitInput))); break}
                    let bk = Int(splitInput[1])
                    if bk != nil {rmbk(path, bk!)}
                    else {print("The commmand \"rmbk\" should take in an integer")}
                case "clrbk":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("clrbk", 0, numArgs(splitInput))); break}
                    breakPoints = [Int]()
                case "disbk":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("disbk", 0, numArgs(splitInput))); break}
                    brksDisabled = true
                case "enbk":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("enbk", 0, numArgs(splitInput))); break}
                    brksDisabled = false
                case "pbk":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("pbk", 0, numArgs(splitInput))); break}
                    pbk(path)
                case "preg":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("preg", 0, numArgs(splitInput))); break}
                    preg()
                case "wreg":
                    if numArgs(splitInput) != 2 {print(wrongNumArgsMessage("wreg", 2, numArgs(splitInput))); break}
                    let number = Int(splitInput[1])
                    if number == nil {print("<number> is supposed to be an integer"); break}
                    let value = Int(splitInput[2])
                    if value == nil {print("<value> is supposed to be an integer"); break}
                    wreg(number!, value!)
                case "wpc":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("wpc", 1, numArgs(splitInput))); break}
                    let value = Int(splitInput[1])
                    if value != nil {instructionPointer = value!}
                    else {print("The commmand \"wpc\" should take in an integer")}
                case "pmem":
                    if numArgs(splitInput) != 2 {print(wrongNumArgsMessage("pmem", 2, numArgs(splitInput))); break}
                    let start = Int(splitInput[1])
                    if start == nil {print("<start> is supposed to be an integer"); break}
                    let end = Int(splitInput[2])
                    if end == nil {print("<end> is supposed to be an integer"); break}
                    pmem(path, start!, end!)
                case "deas":
                    if numArgs(splitInput) != 2 {print(wrongNumArgsMessage("deas", 2, numArgs(splitInput))); break}
                    deassemble(path, splitInput[1], splitInput[2])
                case "wmem":
                    if numArgs(splitInput) != 2 {print(wrongNumArgsMessage("wmem", 2, numArgs(splitInput))); break}
                    let address = Int(splitInput[1])
                    if address == nil {print("<address> is supposed to be an integer"); break}
                    let value = Int(splitInput[2])
                    if value == nil {print("<value> is supposed to be an integer"); break}
                    wmem(path, address!, value!)
                case "pst":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("pst", 0, numArgs(splitInput))); break}
                    asmblr.printSymVal(path)
                case "g":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("g", 0, numArgs(splitInput))); break}
                    executeBinary(path, singleStep: false)
                case "s":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("s", 0, numArgs(splitInput))); break}
                    executeBinary(path, singleStep: true)
                case "help":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("help", 0, numArgs(splitInput))); break}
                    debuggerHelp()
                default: print("\(splitInput[0]) is an invalid debugger command. Please refer back to the help menu and type again carefully")
                }
            }
            print("\nSdb (\(instructionPointer), \(p.mem[instructionPointer]))> ", terminator: "")
            userInput = readLine()!
        }
        asmblr.programs[pIndex!].mem = ogMem
    }
    
    mutating func executeBinary(_ path: String, singleStep: Bool) {
        let p = asmblr.programs[getPIndex(path)!]
        var numExecutedInstructions = 0
        wasCrashed = false
        
        while(isInMemoryBounds(path, instructionPointer)) {
            //first have to check to stop depending on singleStep or not
            if !singleStep {
                if !brksDisabled && breakPoints.contains(instructionPointer) && numExecutedInstructions != 0 {
                    //third condition is to stop g from getting stuck on one breakpoint
                    return
                }
            } else {
                if numExecutedInstructions == 1 {return}
            }
            if wasCrashed == true {return}
            numExecutedInstructions += 1
            
            let pc = instructionPointer
            switch p.mem[instructionPointer] {
            case 0: wasCrashed = false;
            return //halt
            case 1 : clrr(p.mem[pc + 1])
            case 2: clrx(path, p.mem[pc + 1])
            case 3: clrm(path, p.mem[pc + 1])
            case 4: clrb(path, p.mem[pc + 1], p.mem[pc + 2])
            case 5: movir(p.mem[pc + 1], p.mem[pc + 2])
            case 6: movrr(p.mem[pc + 1], p.mem[pc + 2])
            case 7: movrm(path, p.mem[pc + 1], p.mem[pc + 2])
            case 8: movmr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 9: movxr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 10: movar(p.mem[pc + 1], p.mem[pc + 2])
            case 11: movb(path, p.mem[pc + 1], p.mem[pc + 2], p.mem[pc + 3])
            case 12: addir(p.mem[pc + 1], p.mem[pc + 2])
            case 13: addrr(p.mem[pc + 1], p.mem[pc + 2])
            case 14: addmr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 15: addxr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 16: subir(p.mem[pc + 1], p.mem[pc + 2])
            case 17: subrr(p.mem[pc + 1], p.mem[pc + 2])
            case 18: submr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 19: subxr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 20: mulir(p.mem[pc + 1], p.mem[pc + 2])
            case 21: mulrr(p.mem[pc + 1], p.mem[pc + 2])
            case 22: mulmr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 23: mulxr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 24: divir(p.mem[pc + 1], p.mem[pc + 2])
            case 25: divrr(p.mem[pc + 1], p.mem[pc + 2])
            case 26: divmr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 27: divxr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 28: jmp(p.mem[pc + 1])
            case 29: sojz(p.mem[pc + 1], p.mem[pc + 2])
            case 30: sojnz(p.mem[pc + 1], p.mem[pc + 2])
            case 31: aojz(p.mem[pc + 1], p.mem[pc + 2])
            case 32: aojnz(p.mem[pc + 1], p.mem[pc + 2])
            case 33: cmpir(p.mem[pc + 1], p.mem[pc + 2])
            case 34: cmprr(p.mem[pc + 1], p.mem[pc + 2])
            case 35: cmpmr(path, p.mem[pc + 1], p.mem[pc + 2])
            case 36: jmpn(p.mem[pc + 1])
            case 37: jmpz(p.mem[pc + 1])
            case 38: jmpp(p.mem[pc + 1])
            case 39: jsr(p.mem[pc + 1])
            case 40: ret()
            case 41: push(p.mem[pc + 1])
            case 42: pop(p.mem[pc + 1])
            case 43: stackc(p.mem[pc + 1])
            case 44: outci(p.mem[pc + 1])
            case 45: outcr(p.mem[pc + 1])
            case 46: outcx(path, p.mem[pc + 1])
            case 47: outcb(p.mem[pc + 1], p.mem[pc + 2])
            case 48: readi(p.mem[pc + 1], p.mem[pc + 2])
            case 49: printi(p.mem[pc + 1])
            case 50: readc(p.mem[pc + 1])
            case 51: readln(path, p.mem[pc + 1], p.mem[pc + 2])
            case 52: brk(); return //goes back to debugger
            case 53: movrx(path, p.mem[pc + 1], p.mem[pc + 2])
            case 54: movxx(path, p.mem[pc + 1], p.mem[pc + 2])
            case 55: outs(path, p.mem[pc + 1])
            case 56: nop()
            case 57: jmpne(p.mem[pc + 1])
            default:
                numExecutedInstructions -= 1
                print("Error: Nonexistent instruction called, instruction #\(p.mem[instructionPointer]) does not exist")
                wasCrashed = true; return
            }
        }
        print("Error: Index out of bounds, tried to access memory location \(instructionPointer)")
        wasCrashed = true; return
    }
    
    func deassemble(_ path: String, _ sym1: String, _ sym2: String) {
        let pIndex = getPIndex(path)
        let lowerMem = asmblr.programs[pIndex!].symVal[sym1 + ":"]
        if lowerMem == nil {print("The symbol \(sym1) does not exist"); return}
        let upperMem = asmblr.programs[pIndex!].symVal[sym2 + ":"]
        if upperMem == nil {print("The symbol \(sym2) does not exist"); return}
        if lowerMem! > upperMem! {print("The symbol one cannot be past symbol two in memory. Please refer to symbol table and type again"); return}
        
        var toPrint = "Deassembly:\n"
        let mem = asmblr.programs[pIndex!].mem
        var pc = lowerMem!
        while pc <= upperMem! {
            if asmblr.programs[pIndex!].valSym[pc] != nil {
                toPrint += asmblr.programs[pIndex!].valSym[pc]! + "  "
            } else {toPrint += "\t"}
            let instructionString = AssemblerDictionary.instructionCodes[mem[pc]]!
            toPrint += instructionString
            
            let expected = AssemblerDictionary.instructionArgs[instructionString]!
            for i in 0..<expected.count {
                //an instruction takes can take in register, label, or immediate int
                if expected[i] == .Register {
                    toPrint += " r\(mem[pc + i + 1])"
                }
                if expected[i] == .Label {
                    toPrint += " \(Support.removeColon(asmblr.programs[pIndex!].valSym[mem[pc + i + 1]]!))"
                }
                if expected[i] == .ImmediateInteger {
                    toPrint += " #\(mem[pc + i + 1])"
                }
            }
            toPrint += "\n"
            pc += expected.count + 1
        }
        print(toPrint)
    }
    
    
    func bkDescription(_ path: String, _ bk: Int)-> String {
        for (s, v) in asmblr.programs[getPIndex(path)!].symVal {
            if v == bk {
                return "\(bk)  (\(Support.removeColon(s))))"
            }
        }
        return "\(bk)"
    }
    
    mutating func setbk(_ path: String, _ bk: Int) { //ORDER AND INVALID BKS
        if breakPoints.contains(bk) {
            print("\(bkDescription(path, bk)) is already set")
            return
        }
        var insertIndex = 0
        for i in 0..<breakPoints.count {
            if bk < breakPoints[i] {insertIndex = i}
        }
        breakPoints.insert(bk, at: insertIndex)
    }
    
    mutating func rmbk(_ path: String, _ bk: Int) {
        if !breakPoints.contains(bk) {
            print("breakpoint \(bkDescription(path, bk)) cannot be removed as it does not exist")
            return
        }
        breakPoints.remove(at: breakPoints.index(of: bk)!)
    }
    
    func pbk(_ path: String) {
        var toPrint = "\nBreak Points:"
        for bk in breakPoints {
            toPrint += "\n" + bkDescription(path, bk)
        }
        print(toPrint)
    }
    
    func preg() {
        var toPrint = "Registers:\n"
        for n in 0...9 {
            toPrint += "  r\(n):  \(registers[n])\n"
        }
        toPrint += "Program Counter: \(instructionPointer)"
        print(toPrint)
    }
    
    mutating func wreg(_ rNumber: Int, _ value: Int) {
        if rNumber < 0 || rNumber > 9 {
            print("register \(rNumber) does not exist")
            return
        }
        registers[rNumber] = value
    }
    
    func pmem(_ path: String, _ start: Int, _ end: Int) {
        if !isInMemoryBounds(path, start) {
            print("memory location \(start) does not exist")
            return
        }
        if !isInMemoryBounds(path, end) {
            print("memory location \(end) does not exist")
            return
        }
        if start > end {
            print("The start address cannot be after the end address")
            return
        }
        var toPrint = "Memory Dump:\n"
        for i in start...end {
            toPrint += "  \(i):  \(asmblr.programs[getPIndex(path)!].mem[i])\n"
        }
        print(toPrint)
    }
    
    mutating func wmem(_ path: String, _ address: Int, _ value: Int) {
        if !isInMemoryBounds(path, address) {
            print("memory location \(address) does not exist")
            return
        }
        asmblr.programs[getPIndex(path)!].mem[address] = value
    }
    
    func debuggerHelp() {
        var toPrint = "Debugger Help:"
        toPrint += "\n    setbk <address> - set a breakpoint at <address>"
        toPrint += "\n    rmbk <address> - remove breakpoint at <address>"
        toPrint += "\n    clrbk - clear all breakpoints"
        toPrint += "\n    disbk - temporarily disable all breakpoints"
        toPrint += "\n    enbk - enable all breakpoints"
        toPrint += "\n    pbk - print breakpoint table"
        toPrint += "\n    preg - print registers"
        toPrint += "\n    wreg <number> <value> - write <value> to register <number>"
        toPrint += "\n    wpc <value> - change program counter to <value>"
        toPrint += "\n    pmem <start address> <end address> - print contents of memory from <start address> to <end address>"
        toPrint += "\n    wmem <address> <value> - change value of memory at <address> to value"
        toPrint += "\n    deas <symbol 1> <symbol 2> - deassemble from <symbol 1> to <symbol 2>"
        toPrint += "\n    pst - print symbol table"
        toPrint += "\n    g - continue program execution until next breakpoint"
        toPrint += "\n    s - execute a single step"
        toPrint += "\n    help - print this help menu"
        toPrint += "\n    exit - terminate this program's execution"
        print(toPrint)
    }
}





//extension for helpers
extension FullVM {
    func getString(_ path: String, _ labelAddress: Int)->String {
        let pIndex = getPIndex(path)
        var toReturn = ""
        let stringLength = asmblr.programs[pIndex!].mem[labelAddress]
        var pointer = labelAddress + 1
        
        for _ in 1...stringLength {
            toReturn += String(Support.unicodeValueToCharacter(asmblr.programs[pIndex!].mem[pointer]))
            pointer += 1
        }
        return toReturn
    } //finds the string at a given memory address
    
    func isInMemoryBounds(_ path: String, _ address: Int)-> Bool {
        return (0 <= address && address < asmblr.programs[getPIndex(path)!].mem.count)
    } //determines if the instructionPointer is pointing to an existing memory address
    
    func help() {
            var toPrint = "SAP Help:"
            toPrint += "\n    asm <program name> - assemble the specified program"
            toPrint += "\n    run <program name> - run the specified program"
            toPrint += "\n    path <path specification> - set the path for the SAP program directory include final / but not name of file. SAP file must have an extension of .txt"
            toPrint += "\n    printlst <program name> - print listing file for the specified program"
            toPrint += "\n    printbin <program name> - print binary file for the specified program"
            toPrint += "\n    printsym <program name> - pring symbol table for the specified program"
            toPrint += "\n    help - print this help menu"
            toPrint += "\n    quit - quit virtual machine"
            print(toPrint)
    }
    
    func numArgs(_ input: [String])-> Int {
        return input.count - 1
    }
    
    mutating func pushr5to9() {
        for n in 5...9 {
            stack.push(registers[n])
        } //r5 pushed first, r9 last
    }
    //therefore r9 should be popped first, r5 last
    mutating func popr5to9() {
        for n in 1...5 {
            let popped = stack.pop()
            if popped == nil {
                wasCrashed = true
                return
            }
            registers[10 - n] = popped!
        }
    }
}


//extension for executing instructions
extension FullVM {
    /*
     IMPORTANT NOTES:
     Some instructions have to take in path as a parameter; these are the ones that access or change memory. On the other hand, instructions that access and modify registers do not need to take in a path since only memory is unique to each program; only one set of register, status flag, pc, brkpoints, and brksDisabled is stored in the vm whereas multiple memories are stored, one for each program within the assembler
     */
    
    func halt() {return} //0
    
    mutating func clrr(_ rIndex: Int) { //1
        registers[rIndex] = 0
        instructionPointer += 2
    }
    
    mutating func clrx(_ path: String, _ rIndex: Int) { //2
        asmblr.programs[getPIndex(path)!].mem[registers[rIndex]] = 0
        instructionPointer += 2
    }
    
    mutating func clrm(_ path: String, _ labelAddress: Int) { //3
        let pIndex = getPIndex(path)
        asmblr.programs[pIndex!].mem[asmblr.programs[pIndex!].mem[labelAddress]] = 0
        instructionPointer += 2
    }
    
    mutating func clrb(_ path: String, _ r1Index: Int, _ r2Index: Int) { //4
        var startAddress = registers[r1Index]
        let count = registers[r2Index]
        startAddress += 2
        
        for _ in 1...count {
            asmblr.programs[getPIndex(path)!].mem[startAddress] = 0
            startAddress += 1
        }
        instructionPointer += 3
    }
    
    mutating func movir(_ int: Int, _ rIndex: Int) { //5
        registers[rIndex] = int
        instructionPointer += 3
    }
    
    mutating func movrr(_ r1Index: Int, _ r2Index: Int) { //6
        registers[r2Index] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movrm(_ path: String, _ rIndex: Int, _ labelAddress: Int) { //7
        asmblr.programs[getPIndex(path)!].mem[labelAddress] = registers[rIndex]
        instructionPointer += 3
    }
    
    mutating func movmr(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //8
        let labelValue = asmblr.programs[getPIndex(path)!].mem[labelAddress]
        registers[rIndex] = labelValue
        instructionPointer += 3
    }
    
    mutating func movxr(_ path: String, _ r1Index: Int, _ r2Index: Int) { //9
        registers[r2Index] = asmblr.programs[getPIndex(path)!].mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func movar(_ labelAddress: Int, _ rIndex: Int) { //10
        registers[rIndex] = labelAddress
        instructionPointer += 3
    }
    
    mutating func movb(_ path: String, _ r1Index: Int, _ r2Index: Int, _ r3Index: Int) { //11
        let source = registers[r1Index]
        let destination = registers[r2Index]
        let count = registers[r3Index]
        
        let pIndex = getPIndex(path)
        for n in 0..<count {
            asmblr.programs[pIndex!].mem[destination + n] = asmblr.programs[pIndex!].mem[source + n]
        }
        instructionPointer += 4
    }
    
    mutating func addir(_ int: Int, _ rIndex: Int) { //12
        registers[rIndex] += int
        instructionPointer += 3
    }
    
    mutating func addrr(_ r1Index: Int, _ r2Index: Int) { //13
        registers[r2Index] += registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func addmr(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //14
        registers[rIndex] += asmblr.programs[getPIndex(path)!].mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func addxr(_ path: String, _ r1Index: Int, _ r2Index: Int) { //15
        registers[r2Index] += asmblr.programs[getPIndex(path)!].mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func subir(_ int: Int, _ rIndex: Int) { //16
        registers[rIndex] -= int
        instructionPointer += 3
    }
    
    mutating func subrr(_ r1Index: Int, _ r2Index: Int) { //17
        registers[r2Index] -= registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func submr(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //18
        registers[rIndex] -= asmblr.programs[getPIndex(path)!].mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func subxr(_ path: String, _ r1Index: Int, _ r2Index: Int) { //19
        registers[r2Index] *= asmblr.programs[getPIndex(path)!].mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func mulir(_ int: Int, _ rIndex: Int) { //20
        registers[rIndex] *= int
        instructionPointer += 3
    }
    
    mutating func mulrr(_ r1Index: Int, _ r2Index: Int) { //21
        registers[r2Index] *= registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func mulmr(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //22
        registers[rIndex] *= asmblr.programs[getPIndex(path)!].mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func mulxr(_ path: String, _ r1Index: Int, _ r2Index: Int) { //23
        registers[r2Index] *= asmblr.programs[getPIndex(path)!].mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func divir(_ int: Int, _ rIndex: Int) { //24
        registers[rIndex] /= int
        instructionPointer += 3
    }
    
    mutating func divrr(_ r1Index: Int, _ r2Index: Int) { //25
        registers[r2Index] /= registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func divmr(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //26
        registers[rIndex] /= asmblr.programs[getPIndex(path)!].mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func divxr(_ path: String, _ r1Index: Int, _ r2Index: Int) { //27
        registers[r2Index] /= asmblr.programs[getPIndex(path)!].mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func jmp(_ labelAddress: Int) { //28
        instructionPointer = labelAddress
    }
    
    mutating func sojz(_ rIndex: Int, _ labelAddress: Int) { //29
        registers[rIndex] -= 1
        if registers[rIndex] == 0 {
            jmp(labelAddress)
        }
        instructionPointer += 3
    }
    
    mutating func sojnz(_ rIndex: Int, _ labelAddress: Int) { //30
        registers[rIndex] -= 1
        if registers[rIndex] != 0 {
            jmp(labelAddress)
        }
        instructionPointer += 3
    }
    
    mutating func aojz(_ rIndex: Int, _ labelAddress: Int) { //31
        registers[rIndex] += 1
        if registers[rIndex] == 0 {
            jmp(labelAddress)
        }
        instructionPointer += 3
    }
    
    mutating func aojnz(_ rIndex: Int, _ labelAddress: Int) { //32
        registers[rIndex] += 1
        if registers[rIndex] != 0 {
            jmp(labelAddress)
        }
        instructionPointer += 3
    }
    
    mutating func cmpir(_ int: Int, _ rIndex: Int) { //33
        instructionPointer += 3
        let rInt = registers[rIndex]
        if int == rInt {statusFlag.makeEqual(); return}
        if int > rInt {statusFlag.makeMoreThan(); return}
        statusFlag.makeLessThan()
    }
    
    mutating func cmprr(_ r1Index: Int, _ r2Index: Int) { //34
        instructionPointer += 3
        let r1Int = registers[r1Index]
        let r2Int = registers[r2Index]
        if r1Int == r2Int {statusFlag.makeEqual(); return}
        if r1Int > r2Int {statusFlag.makeMoreThan(); return}
        statusFlag.makeLessThan()
    }
    
    mutating func cmpmr(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //35
        instructionPointer += 3
        let rIndex = registers[rIndex]
        let pIndex = getPIndex(path)
        if asmblr.programs[pIndex!].mem[labelAddress] == rIndex {statusFlag.makeEqual(); return}
        if asmblr.programs[pIndex!].mem[labelAddress] > rIndex {statusFlag.makeMoreThan(); return}
        statusFlag.makeLessThan()
    }
    
    mutating func jmpn(_ labelAddress: Int) { //36
        if statusFlag.status == -1{
            instructionPointer = labelAddress
        }
        else{instructionPointer += 2}
    }
    
    mutating func jmpz(_ labelAddress: Int) { //37
        if statusFlag.status == 0{
            instructionPointer = labelAddress
        }
        else{instructionPointer += 2}
    }
    
    mutating func jmpp(_ labelAddress: Int) { //38
        if statusFlag.status == 1{
            instructionPointer = labelAddress
        }
        else{instructionPointer += 2}
    }
    
    mutating func jsr(_ labelAddress: Int) { //39
        pushr5to9()
        retTo.append(instructionPointer + 2)
        //i'm not sure how else this would work since you need to know what memory address to go back to after coming back from a subroutine
        jmp(labelAddress)
        //unconditional jump
    }
    
    mutating func ret() { //40
        popr5to9()
        jmp(retTo.remove(at: retTo.count - 1))
        //unconditional jump
    }
    
    mutating func push(_ rIndex: Int) { //41
        stack.push(registers[rIndex])
        instructionPointer += 2
    }
    //***IMPORTANT*** idk how assembly push and pop are actually used since it would screw with the whole preserving r5 to r9. in order for it not to, i would have to keep pointers in the stack to where each r5 to r9 is and the specs never call for such pointers so i'm assuming that these two instructions would not be used unless the stack does not have any sr saves or they dont care about preserving r5 to r9
    mutating func pop(_ rIndex: Int) { //42
        let popped = stack.pop()
        if popped == nil {wasCrashed = true; return}
        registers[rIndex] = stack.pop()!
        instructionPointer += 2
    }
    
    mutating func stackc(_ rIndex: Int) { //43
        registers[rIndex] = stackRegister
        instructionPointer += 2
    }
    
    mutating func outci(_ int: Int) { //44
        print(Support.unicodeValueToCharacter(int), terminator: "")
        console += String(int)
        instructionPointer += 2
    }
    
    mutating func outcr(_ rIndex: Int) { //45
        print(Support.unicodeValueToCharacter(registers[rIndex]), terminator: "")
        instructionPointer += 2
    }
    
    mutating func outcx(_ path: String, _ rIndex: Int) { //46
        let pIndex = getPIndex(path)
        print(Support.unicodeValueToCharacter(asmblr.programs[pIndex!].mem[registers[rIndex]]), terminator: "")
        console += String(Support.unicodeValueToCharacter(asmblr.programs[pIndex!].mem[registers[rIndex]]))
        instructionPointer += 2
    }
    
    mutating func outcb(_ r1Index: Int, _ r2Index: Int) { //47
        let char = Support.unicodeValueToCharacter(registers[r1Index])
        let count = registers[r2Index]
        for _ in 1...count{print(char, terminator: ""); console += String(char)}
        instructionPointer += 3
    }
    
    mutating func readi(_ r1Index: Int, _ r2Index: Int) { //48
        let digitSet = CharacterSet.decimalDigits
        if digitSet.contains(console.unicodeScalars.last!){
            registers[r1Index] = Int(String(console.last!))!
            registers[r2Index] = 0
        }
        else{
            registers[r2Index] = 1
        }
        instructionPointer += 3
    }
    
    mutating func printi(_ rIndex: Int) { //49
        print(registers[rIndex], terminator: "")
        instructionPointer += 2
    }
    
    mutating func readc(_ rIndex: Int) { //50
        registers[rIndex] = Int(String(console.last!))!
        instructionPointer += 2
    }
    
    mutating func readln(_ path: String, _ labelAddress: Int, _ rIndex: Int) { //51
        let pIndex = getPIndex(path)
        var charactersUni = [Int]()
        let consoleLines = Support.splitStringIntoLines(console)
        let ln = consoleLines.last!
        var i = 1
        for c in ln {charactersUni.append(Support.characterToUnicodeValue(c))}
        asmblr.programs[pIndex!].mem[labelAddress] = ln.count
        while (i - 1) != ln.count{
            asmblr.programs[pIndex!].mem[labelAddress + i] = charactersUni[i - 1]
            i += 1
        }
        registers[rIndex] = ln.count
        instructionPointer += 3
    }
    
    mutating func brk() { //52
        instructionPointer += 1
    }
    
    mutating func movrx(_ path: String, _ r1Index: Int, _ r2Index: Int) { //53
        asmblr.programs[getPIndex(path)!].mem[registers[r2Index]] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movxx(_ path: String, _ r1Index: Int, _ r2Index: Int) { //54
        let pIndex = getPIndex(path)
        asmblr.programs[pIndex!].mem[registers[r2Index]] = asmblr.programs[pIndex!].mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func outs(_ path: String, _ labelAddress: Int) { //55
        let toPrint = getString(path, labelAddress)
        print(toPrint, terminator: "")
        instructionPointer += 2
    }
    
    mutating func nop() { //56
        instructionPointer += 1
    }
    
    mutating func jmpne(_ labelAddress: Int) { //57
        if statusFlag.status != 0 {
            instructionPointer = labelAddress
        } else {
            instructionPointer += 2
        }
    }
}
 
