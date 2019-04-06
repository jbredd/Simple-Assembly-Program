//
//  FullVM.swift
//  PartialVM
//
//  Created by Nicholas Hatzis-Schoch on 4/6/19.
//  Copyright © 2019 Slick Games. All rights reserved.
//

import Foundation

struct FullVM {
    var instructionPointer: Int
    var memory: [Int]
    let size: Int
    let startAddress : Int
    var registers = Array(repeating: 0, count: 10)
    let support = Support()
    var statusFlag = StatusFlag()
    
    //unsure about the mechanics of this one:
    var stackRegister = 0
    
    init(mem: [Int]) {
        memory = mem
        size = mem[0]
        startAddress = mem[1]
        instructionPointer = startAddress + 2 //the plus 2 is because memory actually starts
        //from memory[2] as opposed to memory[0] due to length and startAddress taking 2 spaces
    }
    
    mutating func run() {
        while(true) {
            switch memory[instructionPointer] {
            case 0: return //halt
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
            default: print("invalid instruction")
            }
        }
        print("...Run Finished")
    }
    
    func getString(_ labelAddress: Int)->String {
        var toReturn = ""
        let stringLength = memory[labelAddress]
        var pointer = labelAddress + 1
        
        for _ in 1...stringLength {
            toReturn += String(support.unicodeValueToCharacter(memory[pointer]))
            pointer += 1
        }
        return toReturn
    }
}


//extension for executing instructions
extension FullVM {
    /*
     IMPORTANT NOTES:
     any time that a label address is taken in as a parameter it needs to
     have 2 added it to access the desired memory location since length and
     start address hold the 2 first positions in the memory array
     
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
        memory[registers[rIndex] + 2] = 0
        instructionPointer += 2
    }
    
    mutating func clrm(_ labelAddress: Int) { //3
        memory[memory[labelAddress + 2] + 2] = 0
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
        memory[labelAddress + 2] = registers[rIndex]
        instructionPointer += 3
    }
    
    mutating func movmr(_ labelAddress: Int, _ rIndex: Int) { //8
        let labelValue = memory[labelAddress + 2]
        registers[rIndex] = labelValue
        instructionPointer += 3
    }
    
    mutating func movxr(_ r1Index: Int, _ r2Index: Int) { //9
        registers[r2Index] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movar(_ labelAddress: Int, _ rIndex: Int) { //10
        registers[rIndex] = labelAddress
    }
    
    mutating func movb(_ r1Index: Int, _ r2Index: Int, _ r3Index: Int) { //11 INCOMPLETE
        
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
        registers[rIndex] += memory[labelAddress + 2]
        instructionPointer += 3
    }
    
    mutating func addxr(_ r1Index: Int, _ r2Index: Int) { //15
        registers[r2Index] += memory[registers[r1Index] + 2]
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
        registers[rIndex] -= memory[labelAddress + 2]
        instructionPointer += 3
    }
    
    mutating func subxr(_ r1Index: Int, _ r2Index: Int) { //19
        registers[r2Index] *= memory[registers[r1Index] + 2]
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
        registers[rIndex] *= memory[labelAddress + 2]
        instructionPointer += 3
    }
    
    mutating func mulxr(_ r1Index: Int, _ r2Index: Int) { //23
        registers[r2Index] *= memory[registers[r1Index] + 2]
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
        registers[rIndex] /= memory[labelAddress + 2]
        instructionPointer += 3
    }
    
    mutating func divxr(_ r1Index: Int, _ r2Index: Int) { //27
        registers[r2Index] /= memory[registers[r1Index] + 2]
        instructionPointer += 3
    }
    
    mutating func jmp(_ labelAddress: Int) { //28
        instructionPointer = labelAddress + 2
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
        
        instructionPointer += 3
    }
    
    mutating func aojnz(_ rIndex: Int, _ labelAddress: Int) { //32
        
        instructionPointer += 3
    }
    
    mutating func cmpir(_ int: Int, _ rIndex: Int) { //33
        
        instructionPointer += 3
    }
    
    mutating func cmprr(_ r1Index: Int, _ r2Index: Int) { //34
        let r1Int = registers[r1Index]
        let r2Int = registers[r2Index]
        if r1Int == r2Int {statusFlag.makeEqual(); return}
        if r1Int > r2Int {statusFlag.makeMoreThan(); return}
        statusFlag.makeLessThan()
        instructionPointer += 3
    }
    
    mutating func cmpmr(_ labelAddress: Int, _ rIndex: Int) { //35
        let rIndex = registers[rIndex]
        if rIndex == memory[labelAddress] {statusFlag.makeEqual(); return}
        if rIndex > memory[labelAddress] {statusFlag.makeMoreThan(); return}
        statusFlag.makeLessThan()
        instructionPointer += 3
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
        instructionPointer = labelAddress
        //unconditional jump
    }
    
    mutating func ret() { //40
        //not sure how to implement
        //unconditional jump
    }
    
    mutating func push(_ rIndex: Int) { //41
        //not sure how to implement
        instructionPointer += 2
    }
    
    mutating func pop(_ rIndex: Int) { //42
        //not sure how to implement
        instructionPointer += 2
    }
    
    mutating func stackc(_ rIndex: Int) { //43
        //not sure how to implement
        instructionPointer += 2
    }
    
    mutating func outci(_ int: Int) { //44
        print(int, terminator: "")
        instructionPointer += 2
    }
    
    mutating func outcr(_ rIndex: Int) { //45
        print(support.unicodeValueToCharacter(registers[rIndex]), terminator: "")
        instructionPointer += 2
    }
    
    mutating func outcx(_ rIndex: Int) { //46
        print(support.unicodeValueToCharacter(memory[registers[rIndex]]), terminator: "")
        instructionPointer += 2
    }
    
    mutating func outcb(_ r1Index: Int, _ r2Index: Int) { //47
        let char = support.unicodeValueToCharacter(registers[r1Index])
        let count = registers[r2Index]
        for _ in 1...count{print(char)}
        instructionPointer += 3
    }
    
    mutating func readi(_ r1Index: Int, _ r2Index: Int) { //48
        //not sure how to implement - I believe we may need to implement something to store console outputs
        instructionPointer += 3
    }
    
    mutating func printi(_ rIndex: Int) { //49
        print(registers[rIndex], terminator: "")
        instructionPointer += 2
    }
    
    mutating func readc(_ rIndex: Int) { //50
        //not sure how to implement - I believe we may need to implement something to store console outputs
        instructionPointer += 2
    }
    
    mutating func readln(_ labelAddress: Int, _ rIndex: Int) { //51
        //not sure how to implement - I believe we may need to implement something to store console outputs
        instructionPointer += 3
    }
    
    mutating func brk() { //52
        //not sure how to implement
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
        let toPrint = getString(labelAddress + 2)
        print(toPrint, terminator: "")
        instructionPointer += 2
    }
    
    mutating func nop() { //56
        instructionPointer += 1
    }
    
    mutating func jmpne(_ labelAddress: Int) { //57
        if statusFlag.status != 0 {
            instructionPointer = labelAddress + 2
        } else {
            instructionPointer += 2
        }
    }
}




