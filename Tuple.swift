struct Tuple: CustomStringConvertible {
    let currentState: Int
    let inputCharacter: Int
    let newState: Int
    let outputCharacter: Int
    let direction: Int
    
    var description: String {
        return "{cs: \(currentState), ic: \(inputCharacter), ns: \(newState), oc: \(outputCharacter), di: \(direction)}"
    }
}
