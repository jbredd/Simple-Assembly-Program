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
    var assembler = Assembler()
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
                //for each case first the number of arguments is checked
                case "asm":
                    if numArgs(splitInput) != 1 {
                        print(wrongNumArgsMessage("asm", 1, numArgs(splitInput)))
                        break
                    }
                    assembler.assemble(pathSpecs + splitInput[1] + ".txt")
                case "run":
                    if numArgs(splitInput) != 0 {
                        print(wrongNumArgsMessage("run", 0, numArgs(splitInput)))
                        break
                    }
                    runDebugger()
                    if wasCrashed {print("\n...Binary execution unsuccessful")}
                    else {print("\n...Binary execution successful")}
                case "path":
                    if numArgs(splitInput) != 1 {
                        print(wrongNumArgsMessage("path", 1, numArgs(splitInput)))
                        break
                    }
                    pathSpecs = splitInput[1]
                case "printlst":
                    if numArgs(splitInput) != 0 {
                        print(wrongNumArgsMessage("printlst", 0, numArgs(splitInput)))
                        break
                    }
                    assembler.printLst()
                case "printbin":
                    if numArgs(splitInput) != 0 {
                        print(wrongNumArgsMessage("printbin", 0, numArgs(splitInput)))
                        break
                    }
                    assembler.printBin()
                case "printsym":
                    if numArgs(splitInput) != 0 {
                        print(wrongNumArgsMessage("printsym", 0, numArgs(splitInput)))
                        break
                    }
                    assembler.printSymVal()
                case "help":
                    if numArgs(splitInput) != 0 {
                        print(wrongNumArgsMessage("help", 0, numArgs(splitInput)))
                        break
                    }
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
}

//DEBUGGER EXTENSION
extension FullVM {
    mutating func runDebugger() {
        if assembler.program == nil {print("Please assemble a program first"); return}
        let p = assembler.program!
        let ogMem = p.mem //to ensure that consecutive runs of the same program do not use different memory but the original memory
        registers = Array(repeating: 0, count: 10)
        statusFlag = StatusFlag()
        instructionPointer = assembler.program!.start
        
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
                    if bk != nil {setbk(bk!)}
                    else {print("The commmand \"setbk\" should take in an integer")}
                case "rmbk":
                    if numArgs(splitInput) != 1 {print(wrongNumArgsMessage("rmbk", 1, numArgs(splitInput))); break}
                    let bk = Int(splitInput[1])
                    if bk != nil {rmbk(bk!)}
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
                    pbk()
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
                    pmem(start!, end!)
                case "deas": print("deassembler not done yet")
                case "wmem":
                    if numArgs(splitInput) != 2 {print(wrongNumArgsMessage("wmem", 2, numArgs(splitInput))); break}
                    let address = Int(splitInput[1])
                    if address == nil {print("<address> is supposed to be an integer"); break}
                    let value = Int(splitInput[2])
                    if value == nil {print("<value> is supposed to be an integer"); break}
                    wmem(address!, value!)
                case "pst":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("pst", 0, numArgs(splitInput))); break}
                    assembler.printSymVal()
                case "g":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("g", 0, numArgs(splitInput))); break}
                    executeBinary(singleStep: false)
                case "s":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("s", 0, numArgs(splitInput))); break}
                    executeBinary(singleStep: true)
                case "help":
                    if numArgs(splitInput) != 0 {print(wrongNumArgsMessage("help", 0, numArgs(splitInput))); break}
                    debuggerHelp()
                default: print("\(splitInput[0]) is an invalid debugger command. Please refer back to the help menu and type again carefully")
                }
            }
            print("\nSdb (\(instructionPointer), \(p.mem[instructionPointer]))> ", terminator: "")
            userInput = readLine()!
        }
        assembler.program!.mem = ogMem
    }
    
    mutating func executeBinary(singleStep: Bool) {
        let p = assembler.program!
        var numExecutedInstructions = 0
        while(isInMemoryBounds(instructionPointer)) {
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
            
            switch p.mem[instructionPointer] {
            case 0: wasCrashed = false;
            return //halt
            case 1: clrr(p.mem[instructionPointer + 1])
            case 2: clrx(p.mem[instructionPointer + 1])
            case 3: clrm(p.mem[instructionPointer + 1])
            case 4: clrb(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 5: movir(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 6: movrr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 7: movrm(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 8: movmr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 9: movxr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 10: movar(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 11: movb(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2], p.mem[instructionPointer + 3])
            case 12: addir(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 13: addrr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 14: addmr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 15: addxr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 16: subir(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 17: subrr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 18: submr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 19: subxr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 20: mulir(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 21: mulrr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 22: mulmr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 23: mulxr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 24: divir(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 25: divrr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 26: divmr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 27: divxr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 28: jmp(p.mem[instructionPointer + 1])
            case 29: sojz(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 30: sojnz(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 31: aojz(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 32: aojnz(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 33: cmpir(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 34: cmprr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 35: cmpmr(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 36: jmpn(p.mem[instructionPointer + 1])
            case 37: jmpz(p.mem[instructionPointer + 1])
            case 38: jmpp(p.mem[instructionPointer + 1])
            case 39: jsr(p.mem[instructionPointer + 1])
            case 40: ret()
            case 41: push(p.mem[instructionPointer + 1])
            case 42: pop(p.mem[instructionPointer + 1])
            case 43: stackc(p.mem[instructionPointer + 1])
            case 44: outci(p.mem[instructionPointer + 1])
            case 45: outcr(p.mem[instructionPointer + 1])
            case 46: outcx(p.mem[instructionPointer + 1])
            case 47: outcb(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 48: readi(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 49: printi(p.mem[instructionPointer + 1])
            case 50: readc(p.mem[instructionPointer + 1])
            case 51: readln(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 52: brk()
            case 53: movrx(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 54: movxx(p.mem[instructionPointer + 1], p.mem[instructionPointer + 2])
            case 55: outs(p.mem[instructionPointer + 1])
            case 56: nop()
            case 57: jmpne(p.mem[instructionPointer + 1])
            default:
                numExecutedInstructions -= 1
                print("Error: Nonexistent instruction called, instruction # \(p.mem[instructionPointer]) does not exist")
                wasCrashed = true; return
            }
        }
        wasCrashed = true
        print("Error: Index out of bounds, tried to access memory location \(instructionPointer)")
        return
    }
    
    func bkDescription(_ bk: Int)-> String {
        for (s, v) in assembler.program!.symVal {
            if v == bk {
                return "\(bk)  (\(Support.removeColon(s))))"
            }
        }
        return "\(bk)"
    }
    
    mutating func setbk(_ bk: Int) { //ORDER AND INVALID BKS
        if breakPoints.contains(bk) {
            print("\(bkDescription(bk)) is already set")
            return
        }
        var insertIndex = 0
        for i in 0..<breakPoints.count {
            if bk < breakPoints[i] {insertIndex = i}
        }
        breakPoints.insert(bk, at: insertIndex)
    }
    
    mutating func rmbk(_ bk: Int) {
        if !breakPoints.contains(bk) {
            print("breakpoint \(bkDescription(bk)) cannot be removed as it does not exist")
            return
        }
        breakPoints.remove(at: breakPoints.index(of: bk)!)
    }
    
    func pbk() {
        var toPrint = "\nBreak Points:"
        for bk in breakPoints {
            toPrint += "\n" + bkDescription(bk)
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
    
    func pmem(_ start: Int, _ end: Int) {
        if !isInMemoryBounds(start) {
            print("memory location \(start) does not exist")
            return
        }
        if !isInMemoryBounds(end) {
            print("memory location \(end) does not exist")
            return
        }
        if start > end {
            print("The start address cannot be after the end address")
            return
        }
        var toPrint = "Memory Dump:\n"
        for i in start...end {
            toPrint += "  \(i):  \(assembler.program!.mem[i])\n"
        }
        print(toPrint)
    }
    
    mutating func wmem(_ address: Int, _ value: Int) {
        if !isInMemoryBounds(address) {
            print("memory location \(address) does not exist")
            return
        }
        assembler.program!.mem[address] = value
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
        toPrint += "\n    deas <start address> <end address> - deassemble memory locations"
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
    func getString(_ labelAddress: Int)->String {
        var toReturn = ""
        let stringLength = assembler.program!.mem[labelAddress]
        var pointer = labelAddress + 1
        
        for _ in 1...stringLength {
            toReturn += String(Support.unicodeValueToCharacter(assembler.program!.mem[pointer]))
            pointer += 1
        }
        return toReturn
    } //finds the string at a given memory address
    
    func isInMemoryBounds(_ address: Int)-> Bool {
        return (0 <= address && address < assembler.program!.mem.count)
    } //determines if the instructionPointer is pointing to an existing memory address
    
    func help() {
            var toPrint = "SAP Help:"
            toPrint += "\n    asm <program name> - assemble the specified program"
            toPrint += "\n    run - run the last assembled program"
            toPrint += "\n    path <path specification> - set the path for the SAP program directory include final / but not name of file. SAP file must have an extension of .txt"
            toPrint += "\n    printlst - print listing file for the last assembled program"
            toPrint += "\n    printbin - print binary file for the last assembled program"
            toPrint += "\n    printsym - pring symbol table for the last assembled program"
            toPrint += "\n    help - print this help menu"
            toPrint += "\n    quit - quit virtual machine"
            print(toPrint)
    }
    
    func numArgs(_ args: [String])-> Int {
        return args.count - 1
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
     print statements have the "terminator: String" parameter since swift
     automatically makes the terminator "\n" if not called and we do not want
     to skip any lines when printing except for when outcr-ing #10
     */
    
    func halt() {return} //0
    
    mutating func clrr(_ rIndex: Int) { //1
        registers[rIndex] = 0
        instructionPointer += 2
    }
    
    mutating func clrx(_ rIndex: Int) { //2
        assembler.program!.mem[registers[rIndex]] = 0
        instructionPointer += 2
    }
    
    mutating func clrm(_ labelAddress: Int) { //3
        assembler.program!.mem[assembler.program!.mem[labelAddress]] = 0
        instructionPointer += 2
    }
    
    mutating func clrb(_ r1Index: Int, _ r2Index: Int) { //4
        var startAddress = registers[r1Index]
        let count = registers[r2Index]
        startAddress += 2
        
        for _ in 1...count {
            assembler.program!.mem[startAddress] = 0
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
    
    mutating func movrm(_ rIndex: Int, _ labelAddress: Int) { //7
        assembler.program!.mem[labelAddress] = registers[rIndex]
        instructionPointer += 3
    }
    
    mutating func movmr(_ labelAddress: Int, _ rIndex: Int) { //8
        let labelValue = assembler.program!.mem[labelAddress]
        registers[rIndex] = labelValue
        instructionPointer += 3
    }
    
    mutating func movxr(_ r1Index: Int, _ r2Index: Int) { //9
        registers[r2Index] = assembler.program!.mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func movar(_ labelAddress: Int, _ rIndex: Int) { //10
        registers[rIndex] = labelAddress
        instructionPointer += 3
    }
    
    mutating func movb(_ r1Index: Int, _ r2Index: Int, _ r3Index: Int) { //11
        let source = registers[r1Index]
        let destination = registers[r2Index]
        let count = registers[r3Index]
        
        for n in 0..<count {
            assembler.program!.mem[destination + n] = assembler.program!.mem[source + n]
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
    
    mutating func addmr(_ labelAddress: Int, _ rIndex: Int) { //14
        registers[rIndex] += assembler.program!.mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func addxr(_ r1Index: Int, _ r2Index: Int) { //15
        registers[r2Index] += assembler.program!.mem[registers[r1Index]]
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
    
    mutating func submr(_ labelAddress: Int, _ rIndex: Int) { //18
        registers[rIndex] -= assembler.program!.mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func subxr(_ r1Index: Int, _ r2Index: Int) { //19
        registers[r2Index] *= assembler.program!.mem[registers[r1Index]]
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
    
    mutating func mulmr(_ labelAddress: Int, _ rIndex: Int) { //22
        registers[rIndex] *= assembler.program!.mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func mulxr(_ r1Index: Int, _ r2Index: Int) { //23
        registers[r2Index] *= assembler.program!.mem[registers[r1Index]]
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
    
    mutating func divmr(_ labelAddress: Int, _ rIndex: Int) { //26
        registers[rIndex] /= assembler.program!.mem[labelAddress]
        instructionPointer += 3
    }
    
    mutating func divxr(_ r1Index: Int, _ r2Index: Int) { //27
        registers[r2Index] /= assembler.program!.mem[registers[r1Index]]
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
    
    mutating func cmpmr(_ labelAddress: Int, _ rIndex: Int) { //35
        instructionPointer += 3
        let rIndex = registers[rIndex]
        if assembler.program!.mem[labelAddress] == rIndex {statusFlag.makeEqual(); return}
        if assembler.program!.mem[labelAddress] > rIndex {statusFlag.makeMoreThan(); return}
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
    
    mutating func outcx(_ rIndex: Int) { //46
        print(Support.unicodeValueToCharacter(assembler.program!.mem[registers[rIndex]]), terminator: "")
        console += String(Support.unicodeValueToCharacter(assembler.program!.mem[registers[rIndex]]))
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
    
    mutating func readln(_ labelAddress: Int, _ rIndex: Int) { //51
        var charactersUni = [Int]()
        let consoleLines = Support.splitStringIntoLines(console)
        let ln = consoleLines.last!
        var i = 1
        for c in ln {charactersUni.append(Support.characterToUnicodeValue(c))}
        assembler.program!.mem[labelAddress] = ln.count
        while (i - 1) != ln.count{
            assembler.program!.mem[labelAddress + i] = charactersUni[i - 1]
            i += 1
        }
        registers[rIndex] = ln.count
        instructionPointer += 3
    }
    
    mutating func brk() { //52
        //not sure how to implement (if even possible without the debugger)
        instructionPointer += 1
    }
    
    mutating func movrx(_ r1Index: Int, _ r2Index: Int) { //53
        assembler.program!.mem[registers[r2Index]] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movxx(_ r1Index: Int, _ r2Index: Int) { //54
        assembler.program!.mem[registers[r2Index]] = assembler.program!.mem[registers[r1Index]]
        instructionPointer += 3
    }
    
    mutating func outs(_ labelAddress: Int) { //55
        let toPrint = getString(labelAddress)
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
