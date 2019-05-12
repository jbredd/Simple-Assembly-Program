struct Line {
    var characters: [Character]
    var chunks = [String]()
    var tokens = [Token]()
    var number: Int
    
    init(_ number: Int, _ line: String) {
        characters = Array(line)
        self.number = number
    }
}
