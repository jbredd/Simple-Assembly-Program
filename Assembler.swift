import Foundation

struct Assembler{
    var inputCode = [String]()
    let support = Support()
    var userInput = ""
    init(){}
}

extension Assembler{
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
    func lineToChunks(c: [Character])->[[Character]]{
        var interceptions = [Int]()
        var chunks = [[Character]]()
        for i in 0..<c.count{
            if c[i] == " "{
                interceptions.append(i)
            }
            if c[i] == "\""{
                interceptions.append(i)
            }
            if c[i] == "\\"{
                interceptions.append(i)
            }
        }
        for i in 0..<interceptions.count{
            if i != 0 && i != interceptions.count - 1{
                if c[interceptions[i-1]] == c[interceptions[i+1]] && c[interceptions[i-1]] != " " && c[interceptions[i+1]] != " "{
                    interceptions.remove(at: i)
                }
            }
        }
        for i in 0..<interceptions.count{
            if i == 0{
                chunks.append(Array(c[0..<interceptions[i]]))
            }
            if i+1 < interceptions.count && c[interceptions[i]] == " " && c[interceptions[i+1]] == " "{
                chunks.append(Array(c[interceptions[i] + 1..<interceptions[i+1]]))
            }
            if i+1 < interceptions.count && c[interceptions[i]] == "\"" && c[interceptions[i+1]] == "\""{
                chunks.append(Array(c[interceptions[i]...interceptions[i+1]]))
            }
            if i+1 < interceptions.count && c[interceptions[i]] == "\\" && c[interceptions[i+1]] == "\\"{
                chunks.append(Array(c[interceptions[i]...interceptions[i+1]]))
            }
            if i+1 == interceptions.count{
                chunks.append(Array(c[interceptions[i] + 1..<c.count]))
            }
        }
        return chunks
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
}
