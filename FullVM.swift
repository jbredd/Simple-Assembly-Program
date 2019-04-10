import Foundation

struct FullVM {
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
    
    var stackRegister = 0
    var console: String = ""
    
    /*
    init(binary: [Int]) {
        size = binary[0]
        startAddress = binary[1]
        instructionPointer = startAddress
        for n in 2..<binary.count { //binary[0] and binary[1] not part of memory
            memory[n - 2] = binary[n]
        }
    }*/
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
        instructionPointer = startAddress
        while(pointerIsInMemoryBounds()) {
            switch memory[instructionPointer] {
            case 0: wasCrashed = false; return
            case 6: movrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 8: movmr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 12: addir(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 13: addrr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 34: cmprr(memory[instructionPointer + 1], memory[instructionPointer + 2])
            case 45: outcr(memory[instructionPointer + 1])
            case 49: printi(memory[instructionPointer + 1])
            case 55: outs(memory[instructionPointer + 1])
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
        registers[r2Index] = registers[r1Index]
        instructionPointer += 3
    }
    
    mutating func movar(_ labelAddress: Int, _ rIndex: Int) { //10
        registers[rIndex] = labelAddress
        instructionPointer += 3
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
        if rIndex == memory[labelAddress] {statusFlag.makeEqual(); return}
        if rIndex > memory[labelAddress] {statusFlag.makeMoreThan(); return}
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
