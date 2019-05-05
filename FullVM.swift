//
//  FullVM.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/26/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//
import Foundation

struct FullVM {
    //runs the assembly binary code for the Doubles Program
    var instructionPointer = 0
    var memory = Array(repeating: 0, count: 1000)
    var binary = [0]
    var size = 0
    var startAddress = 0
    var registers = Array(repeating: 0, count: 10)
    var statusFlag = StatusFlag()
    
    var stack = Stack<Int>(size: 200)
    let support = Support()
    var userInput = ""
    var wasCrashed = false
    
    var stackRegister: Int {
        if stack.isEmpty() {return 2}
        if stack.isFull() {return 1}
        return 0
    }
    var console: String = ""
    var retTo = [Int]()
    

    init() {}
    
    mutating func run() {
        print("Welcome to the binary to ouput virtual machine!")
        help()
        print(">", terminator: "")
        userInput = readLine()!
        while userInput != "quit" {
            var splitInput = support.splitStringIntoParts(userInput)
            switch splitInput[0] {
            //for each case first the number of arguments is checked and then whether the type of the argument is as expected
            case "read":
                if numArgs(splitInput) != 1 {print("The command 'read' takes in 1 argument, you put in \(numArgs(splitInput)). Please type again carefully\n"); break}
                read(splitInput[1])
            case "run":
                if numArgs(splitInput) != 0 {print("The command 'run' takes in 0 arguments, you put in \(numArgs(splitInput)). Please type again carefully\n"); break};
                executeBinary()
                if wasCrashed {print("\n...Binary execution unsuccessful")}
                else {print("\n...Binary execution successful")}
            case "help":
                if numArgs(splitInput) != 0 {print("The command 'help' takes in 0 arguments, you put in \(numArgs(splitInput)). Please type again carefully\n"); break}
                help()
            case "quit":
                if numArgs(splitInput) != 0 {print("The command 'quit' takes in 0 arguments, you put in \(numArgs(splitInput)). Please type again carefully\n"); break}
                return
            default: print("'\(userInput)' is an invalid command. Please type again carefully\n")
            }
            print(">", terminator: "")
            userInput = readLine()!
        }
    }
    
    mutating func executeBinary() {
        for i in 0..<memory.count {
            print("\(i):   \(memory[i])")
        }
        instructionPointer = startAddress
        while(pointerIsInMemoryBounds()) {
            if wasCrashed == true {return}
            switch memory[instructionPointer] {
            case 0: wasCrashed = false;
            /*
                for i in 0..<memory.count {
                    print("\(i):   \(memory[i])")
                }*/
                return //halt
            case 1: clrr(memory[instructionPointer + 1])
            case 2: clrx(memory[instructionPointer + 1])
            case 3: clrm(memory[instructionPointer + 1])
            case 4: clrb(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 5: movir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 6: movrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 7: movrm(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 8: movmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 9: movxr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 10: movar(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 11: movb(memory[instructionPointer + 1], memory[instructionPointer + 2], memory[instructionPointer + 3])
            case 12: addir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 13: addrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 14: addmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 15: addxr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 16: subir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 17: subrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 18: submr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 19: subxr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 20: mulir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 21: mulrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 22: mulmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 23: mulxr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 24: divir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 25: divrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 26: divmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 27: divxr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 28: jmp(memory[instructionPointer + 1])
            case 29: sojz(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 30: sojnz(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 31: aojz(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 32: aojnz(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 33: cmpir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 34: cmprr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 35: cmpmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 36: jmpn(memory[instructionPointer + 1])
            case 37: jmpz(memory[instructionPointer + 1])
            case 38: jmpp(memory[instructionPointer + 1])
            case 39: jsr(memory[instructionPointer + 1])
            case 40: ret()
            case 41: push(memory[instructionPointer + 1])
            case 42: pop(memory[instructionPointer + 1])
            case 43: stackc(memory[instructionPointer + 1])
            case 44: outci(memory[instructionPointer + 1])
            case 45: outcr(memory[instructionPointer + 1])
            case 46: outcx(memory[instructionPointer + 1])
            case 47: outcb(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 48: readi(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 49: printi(memory[instructionPointer + 1])
            case 50: readc(memory[instructionPointer + 1])
            case 51: readln(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 52: brk()
            case 53: movrx(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 54: movxx(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 55: outs(memory[instructionPointer + 1])
            case 56: nop()
            case 57: jmpne(memory[instructionPointer + 1])
            default:
                print("Error: Nonexistent instruction called, instruction # \(memory[instructionPointer]) does not exist")
                wasCrashed = true; return
            }
        }
        wasCrashed = true
        print("Error: Index out of bounds, tried to access memory location \(instructionPointer)")
        return
    }
}


//extension for helpers
extension FullVM {
    func getString(_ labelAddress: Int)->String {
        var toReturn = ""
        let stringLength = memory[labelAddress]
        var pointer = labelAddress + 1
        
        for _ in 1...stringLength {
            toReturn += String(support.unicodeValueToCharacter(memory[pointer]))
            pointer += 1
        }
        return toReturn
    } //finds the string at a given memory address
    
    func pointerIsInMemoryBounds()-> Bool {
        return (0 <= instructionPointer && instructionPointer < memory.count)
    } //determines if the instructionPointer is pointing to an existing memory address
    
    func help() {
        var toReturn = "Full Virtual Machine Help:"
        toReturn += "\n    read <path> - read file and write its binary to memory"
        toReturn += "\n    run - execute the binary"
        toReturn += "\n    help - print this help menu"
        toReturn += "\n    quit - quit virtual machine"
        print(toReturn)
    } //prints help menu
    
    mutating func read(_ path: String) {
        if support.readTextFile(path).fileText == nil {
            print(support.readTextFile(path).message!)
            return
        }
        let fileContent = support.readTextFile(path).fileText!
        print(fileContent)
        
        let binaryStrings = support.splitStringIntoLines(fileContent)
        binary = Array(repeating: 0, count: binaryStrings.count)
        for n in 0..<binaryStrings.count {
            if Int(binaryStrings[n]) != nil {
                binary[n] = Int(binaryStrings[n])!
            } else {print("...file contained nonbinary elements, cannot be read to memory"); return}
        }
        size = binary[0]
        startAddress = binary[1]
        instructionPointer = startAddress
        for n in 2..<binary.count { //binary[0] and binary[1] not part of memory
            memory[n - 2] = binary[n]
        }
        print("...reading binary file complete")
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
            var popped = stack.pop()
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
        memory[registers[rIndex]] = 0
        instructionPointer += 2
    }
    
    mutating func clrm(_ labelAddress: Int) { //3
        memory[memory[labelAddress]] = 0
        instructionPointer += 2
    }
    
    mutating func clrb(_ r1Index: Int, _ r2Index: Int) { //4
        var startAddress = registers[r1Index]
        let count = registers[r2Index]
        startAddress += 2
        
        for _ in 1...count {
            memory[startAddress] = 0
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
        memory[labelAddress] = registers[rIndex]
        instructionPointer += 3
    }
    
    mutating func movmr(_ labelAddress: Int, _ rIndex: Int) { //8
        let labelValue = memory[labelAddress]
        registers[rIndex] = labelValue
        instructionPointer += 3
    }
    
    mutating func movxr(_ r1Index: Int, _ r2Index: Int) { //9
        registers[r2Index] = memory[registers[r1Index]]
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
            memory[destination + n] = memory[source + n]
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
        registers[rIndex] += memory[labelAddress]
        instructionPointer += 3
    }
    
    mutating func addxr(_ r1Index: Int, _ r2Index: Int) { //15
        registers[r2Index] += memory[registers[r1Index]]
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
        registers[rIndex] -= memory[labelAddress]
        instructionPointer += 3
    }
    
    mutating func subxr(_ r1Index: Int, _ r2Index: Int) { //19
        registers[r2Index] *= memory[registers[r1Index]]
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
        registers[rIndex] *= memory[labelAddress]
        instructionPointer += 3
    }
    
    mutating func mulxr(_ r1Index: Int, _ r2Index: Int) { //23
        registers[r2Index] *= memory[registers[r1Index]]
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
        registers[rIndex] /= memory[labelAddress]
        instructionPointer += 3
    }
    
    mutating func divxr(_ r1Index: Int, _ r2Index: Int) { //27
        registers[r2Index] /= memory[registers[r1Index]]
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
        if memory[labelAddress] == rIndex {statusFlag.makeEqual(); return}
        if memory[labelAddress] > rIndex {statusFlag.makeMoreThan(); return}
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
        print(support.unicodeValueToCharacter(int), terminator: "")
        console += String(int)
        instructionPointer += 2
    }
    
    mutating func outcr(_ rIndex: Int) { //45
        print(support.unicodeValueToCharacter(registers[rIndex]), terminator: "")
        instructionPointer += 2
    }
    
    mutating func outcx(_ rIndex: Int) { //46
        print(support.unicodeValueToCharacter(memory[registers[rIndex]]), terminator: "")
        console += String(support.unicodeValueToCharacter(memory[registers[rIndex]]))
        instructionPointer += 2
    }
    
    mutating func outcb(_ r1Index: Int, _ r2Index: Int) { //47
        let char = support.unicodeValueToCharacter(registers[r1Index])
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
        let consoleLines = support.splitStringIntoLines(console)
        let ln = consoleLines.last!
        var i = 1
        for c in ln {charactersUni.append(support.characterToUnicodeValue(c))}
        memory[labelAddress] = ln.count
        while (i - 1) != ln.count{
            memory[labelAddress + i] = charactersUni[i - 1]
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
        memory[registers[r2Index]] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movxx(_ r1Index: Int, _ r2Index: Int) { //54
        memory[registers[r2Index]] = memory[registers[r1Index]]
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
