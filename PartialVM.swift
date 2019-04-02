import Foundation

struct PartialVM {
    //runs the assembly binary code for the Doubles Program
    var instructionPointer = 0
    var memory = Array(repeating: 0, count: 10000)
    var binary = [0]
    var size = 0
    var startAddress = 0
    var registers = Array(repeating: 0, count: 10)
    var statusFlag = StatusFlag()
    
    let support = Support()
    var userInput = ""
    var wasCrashed = false
    
    
    init(binary: [Int]) {
        size = binary[0]
        startAddress = binary[1]
        instructionPointer = startAddress
        for n in 2..<binary.count { //binary[0] and binary[1] not part of memory
            memory[n - 2] = binary[n]
        }
    }
    
    mutating func run() {
        print("Welcome to the binary to ouput virtual machine!")
        help()
        print(">", terminator: "")
        userInput = readLine()!
        while userInput != "quit" {
            var splitInput = support.splitStringIntoParts(expression: userInput)
            switch splitInput[0] {
                /*
                case "write":
                    print("please type in the binary you would like to write, each element separated by a space:")
                    userInput = readLine()!
                    let data = userInput
                    /*
                    let path = splitInput[1]
                    var dataArray = splitInput
                    dataArray.removeFirst(); dataArray.removeFirst(); dataArray.removeFirst()
                    var data = ""
                    for d in dataArray {data += "\(d)\n"}
                    data.removeLast()
                    */
                    
                    print(support.writeTextFile(splitInput[1], data: data))
                case "read": read(splitInput[1])*/
                case "run":
                    executeBinary()
                    if wasCrashed {print("...binary execution unsuccessful")}
                    else {print("...binary execution successful")}
                case "help": help()
                case "quit": return
                default: print("invalid input, please type again carefully")
            }
            print(">", terminator: "")
            userInput = readLine()!
        }
    }
    
    func help() {
        var toReturn = "Partial Virtual Machine Help:"
        toReturn += "\n    //write <path>"
        toReturn += "\n    //<data> - write a file of binary"
        toReturn += "\n    //read <path> - read file and write its binary to memory"
        toReturn += "\n    run - execute the binary"
        toReturn += "\n    help - print this help menu"
        toReturn += "\n    quit - quit virtual machine"
        print(toReturn)
    }
    
    mutating func executeBinary() {
        while(true) {
            switch memory[instructionPointer] {
                case 0: return //ERROR: for some reason this case is not executing, executeBinary can't be exited
                case 6: movrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 8: movmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 12: addir(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 13: addrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 34: cmprr(memory[instructionPointer + 1], memory[instructionPointer + 2])
                case 45: outcr(memory[instructionPointer + 1])
                case 49: printi(memory[instructionPointer + 1])
                case 55: outs(memory[instructionPointer + 1])
                case 57: jmpne(memory[instructionPointer + 1])
                default: print("nonexistent instruction called"); wasCrashed = true; return
            }
        }
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


//extension for helpers
extension PartialVM {
    /*
    mutating func write() {
        
    }
    
    mutating func read(_ path: String) {
        let fileContent = support.readTextFile(path).fileText!
        let binaryStrings = support.splitStringIntoLines(expression: fileContent)
        var binary = [Int]()
        for s in binaryStrings {
            if Int(s) != nil {
                binary.append(Int(s)!)
            } else {print("...file contained nonbinary elements, cannot be read to memory")}
        }
        size = binary[0]
        startAddress = binary[1]
        instructionPointer = startAddress
        for n in 2..<binary.count { //binary[0] and binary[1] not part of memory
            memory[n - 2] = binary[n]
        }
        print("...reading binary file complete")
    }
    */
    
}


//extension for executing instructions
extension PartialVM {
    /*
     IMPORTANT NOTES:
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
        let labelValue = memory[labelAddress]
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
        let toPrint = getString(labelAddress)
        print(toPrint, terminator: "")
        instructionPointer += 2
    }
    
    mutating func jmpne(_ labelAddress: Int) { //57
        if statusFlag.status != 0 {
            instructionPointer = labelAddress
        } else {
            instructionPointer += 2
        }
    }
}
