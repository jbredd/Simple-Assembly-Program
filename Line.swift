import Foundation

struct Line: CustomStringConvertible {
    var characters: [Character]
    var chunks = [String]()
    var tokens = [Token]()
    var number: Int
    var tokenizer = Tokenizer()
    
    init(_ number: Int, _ line: String) {
        characters = Array(line)
        self.number = number
        chunkinize(characters)
        tokens = tokenizer.tokenizeChunks(chunks)
    }
    
    mutating func chunkinize(_ characters: [Character]) {
        var ignoreSpaces = false
        var chunk = ""
        for i in 0..<characters.count {
            if !ignoreSpaces {
                if characters[i] == " " {
                    chunks.append(chunk)
                    chunk = ""
                } else {
                    chunk += String(characters[i])
                    if characters[i] == "\"" || characters[i] == "\\" {ignoreSpaces = true}
                    if i == characters.count - 1 {chunks.append(chunk)}
                }
            } else {
                chunk += String(characters[i])
                if characters[i] == "\"" || characters[i] == "\\" {
                    ignoreSpaces = false
                }
                if i == characters.count - 1 {chunks.append(chunk)}
            }
        }
        var cChunks = charChunks()
        if cChunks.count > 0{
            for i in 0..<cChunks.count{
                if cChunks[i][0] == ";"{
                    chunks.removeSubrange(i..<cChunks.count)
                }
            }
        }
        chunks = chunks.filter{$0.count > 0}
    }
    func charChunks()->[[Character]]{
        var chChunks = [[Character]]()
        for c in chunks{
            chChunks.append(Array(c))
        }
        return chChunks
    }
    func printLine() {
        for c in chunks {print("\(c) ")}
    }
    
    var description: String {
        var description = "Line #\(number):\n"
        description += "  characters: \(characters)\n"
        description += "  chunks: \(chunks)\n"
        description += "  tokens: \(tokens)\n"
        return description
    }
}
