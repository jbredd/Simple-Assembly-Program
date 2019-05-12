struct Tokenizer {
    let chars = Set(Array("abcdefghijklmnopqrstuvwxyz"))
    let digits = Set(Array("0123456789"))
    
    func tokenizeChunks(_ chunks: [String]) {
        var tokens = [Token]()
        for c in chunks {
            tokens.append(tokenizeChunk(c))
        }
    }
    func tokenizeChunk(_ chunk: String)-> Token {
        let chunkChars = Array(chunk)
        let firstChar = chunkChars[0]
        let lastChar = chunkChars[chunkChars.count - 1]
        /*
         check if it is instruction
         check if it is register
         check if it is label
         check if it is label definition
         
         check if it is an immediate or a directive
        */
        switch firstChar {
        case "\"":
            if lastChar == "\"" && chunkChars.count >= 2 {
                return Token(.ImmediateString, sValue: getString(chunk))
            } else {return Token(.BadToken)}
        case "\\":
            if lastChar == "\\" {}
        }
    }
    
    func getString(_ chunk: String)-> String {
        var toRet = ""
        let chunkChars = Array(chunk)
        for i in 1...chunk.count - 2 {
            toRet += String(chunkChars[i])
        }
        return toRet
    }
    
    func isRegister(_ chunk: String)-> Bool {
        let chunkChars = Array(chunk)
        return chars.contains(chunkChars[0]) && digits.contains(chunkChars[1]) && chunkChars.count == 2
    }
    
    func isLabel(_ chunk: String)-> Bool {
        let chunkChars = Array(chunk)
        if !chars.contains(chunkChars[0]) {return false}
        for i in 1..<chunkChars.count {
            if !chars.contains(chunkChars[i]) && !digits.contains(chunkChars[i]) {return false}
        }
        return true
    }
    
    
    func isInstruction(_ chunk: String)-> Bool {
        return true
    }
}
