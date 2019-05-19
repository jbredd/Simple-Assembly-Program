import Foundation

struct Assembler{
    var inputCode = [String]()
    var legalProgram = false
    var binary = [Int]()
    let support = Support()
    var instructionArgs: [String: [TokenType]] = [:]
    var directiveArgs: [String : [TokenType]] = [:]
    var symVal: [String: Int] = [:]
    var userInput = ""
    init() {fillDictionary()}
    
    func help(){
        var toReturn = "Full Virtual Machine Help:"
        toReturn += "\n    asm <program name> - assemble the specified program"
        toReturn += "\n    run <program name> - run the specified program"
        toReturn += "\n    path <path specification> - set the path for the SAP program directory include final / but not name of file. SAP file must have an extension of .txt"
        toReturn += "\n    printlst <program name> - print listing file for the specified program"
        toReturn += "\n    printbin <program name> - print binary file for the specified program"
        toReturn += "\n    help - print this help menu"
        toReturn += "\n    quit - quit virtual machine"
        print(toReturn)
    }
    
    mutating func read(_ path: String) {
        if support.readTextFile(path).fileText == nil {
            print(support.readTextFile(path).message!)
            return
        }
        let fileContent = support.readTextFile(path).fileText!
        print(fileContent)
        self.inputCode = support.splitStringIntoLines(fileContent)
        print("...SAP file reading complete")
    }
    
    func makeLines()-> [Line] {
        var lines = [Line]()
        for i in 0..<inputCode.count {
            lines.append(Line(i, inputCode[i]))
        }
        return lines
    }
    
    mutating func assemble() {
        passOne()
        passTwo()
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
}

// PASS ONE
extension Assembler{
    mutating func passOne() {
        legalProgram = true
        let lines = makeLines()
        makeSymVal(lines)
        for l in lines {
            l.printLine()
            if !isLegal(l).0 {legalProgram = false}
            print(isLegal(l).1)
        }
    }
    
    mutating func makeSymVal(_ lines: [Line]) {
        for l in lines {
            for i in 0..<l.tokens.count {
                if l.tokens[i].type == .LabelDefinition {
                    symVal[l.chunks[i]] = l.number
                }
            }
        }
    }
    
    func isLegal(_ line: Line)-> (Bool, String) {
        let chunks = line.chunks
        let tokens = line.tokens
        switch tokens[0].type {
        case .Instruction: return validInstructionArgs(line)
        case .Directive: return validDirectiveArg(line)
        case .LabelDefinition:
            if line.tokens[1].type == .Instruction {return validInstructionArgs(line)} // THIS LINE IS WRONG
            return (false, "\n..........A Label Definition must be followed by an Instruction")
        case .BadToken: return (false, "\n..........\(chunks[0]) is a Bad Token")
        default: return (false, "\n..........Line must start with an Instruction, Directive, or Label Definition")
        }
    }
    
    func validDirectiveArg(_ line: Line)-> (Bool, String) {
        let expected = directiveArgs[line.chunks[0]]
        if line.tokens.count != 2 {return (false, "\n..........Directives should take in one argument")}
        if line.tokens[1].type == expected![0] {return (true, "")}
        return (false, "\n..........\(line.chunks[0]) should take in a \(expected![0])")
    }
    
    func validInstructionArgs(_ line: Line)-> (Bool, String) {
        let expected = instructionArgs[line.chunks[0]]
        if line.tokens.count > expected!.count + 1 {return (false, "\n..........\(line.chunks[0]) has too many arguments")}
        for i in 0..<expected!.count {
            if line.tokens[i+1].type != expected![i] {
                return (false, "\n..........Instruction \(line.chunks[0]) arguments are not as expected")
            }
        }
        return (true, "")
    }
}

// PASS TWO
extension Assembler {
    mutating func passTwo() {
        if !legalProgram {return}
        translate()
    }
    
    mutating func translate() {
        let lines = makeLines()
        for l in lines {
            for i in 0..<l.tokens.count {
                switch l.tokens[i].type {
                case .Register: binary.append(Translator.registers[l.chunks[i]]!)
                case .ImmediateString: translateString(l.tokens[i].stringValue!)
                case .ImmediateInteger: binary.append(l.tokens[i].intValue!)
                case .ImmediateTuple: translateTuple(l.tokens[i])
                case .Instruction: binary.append(Translator.instructions[l.chunks[i]]!)
                default: print("wut")
                }
            }
        }
    }
    // \0 _ 0 _ r\
    mutating func translateTuple(_ token: Token) {
        binary.append(token.tupleValue!.currentState) //should be cs
        binary.append(support.characterToUnicodeValue(token.tupleValue!.inputCharacter)) //should be ic
        binary.append(token.tupleValue!.newState) //should be ns
        binary.append(support.characterToUnicodeValue(token.tupleValue!.outputCharacter)) //should be oc
        binary.append(token.tupleValue!.direction) //should be di
    }
    
    mutating func translateString(_ string: String) {
        let stringChars = Array(string)
        binary.append(stringChars.count)
        for c in stringChars {
            binary.append(support.characterToUnicodeValue(c))
        }
    }
}
