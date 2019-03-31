//
//  VM.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 3/26/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation

struct PartialVM {
    //runs the assembly binary code for the Doubles Program
    var instructionPointer: Int
    let memory: [Int]
    let size: Int
    let startAddress : Int
    var registers = Array(repeating: 0, count: 10)
    let support = Support()
    var statusFlag = StatusFlag()
    
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
                case 0: return
                case 6: movrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 8: movmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 12: addir(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 13: addrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 34: cmprr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 45: outcr(memory[instructionPointer + 1])
                case 49: printi(memory[instructionPointer + 1])
                case 55: outs(memory[instructionPointer + 1])
                case 57: jmpne(memory[instructionPointer + 1])
                default: print("invalid")
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
            //print(support.unicodeValueToCharacter(memory[pointer]))
            //print(pointer)
            pointer += 1
        }
        return toReturn
    }
}


//extension for executing instructions
extension PartialVM {
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
    
    mutating func movrr(_ r1Index: Int, _ r2Index: Int) { //6
        registers[r2Index] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movmr(_ labelAddress: Int, _ rIndex: Int) { //8
        let labelValue = memory[labelAddress + 2]
        registers[rIndex] = labelValue
        instructionPointer += 3
    }
    
    mutating func addir(_ int: Int, _ rIndex: Int) { //12
        registers[rIndex] += int
        instructionPointer += 3
    }
    
    mutating func addrr(_ r1Index: Int, _ r2Index: Int) { //13
        registers[r2Index] += registers[r1Index]
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
    
    mutating func outcr(_ rIndex: Int) { //45
        print(support.unicodeValueToCharacter(registers[rIndex]), terminator: "")
        instructionPointer += 2
    }
    
    mutating func printi(_ rIndex: Int) { //49
        print(registers[rIndex], terminator: "")
        instructionPointer += 2
    }
    
    mutating func outs(_ labelAddress: Int) { //55
        let toPrint = getString(labelAddress + 2)
        print(toPrint, terminator: "")
        instructionPointer += 2
    }
    
    mutating func jmpne(_ labelAddress: Int) { //57
        if statusFlag.status != 0 {
            instructionPointer = labelAddress + 2
        } else {
            instructionPointer += 2
        }
    }
}














