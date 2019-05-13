import Foundation

struct Tuple: CustomStringConvertible {
    let currentState: Int
    let inputCharacter: Character
    let newState: Int
    let outputCharacter: Character
    let direction: Character
    
    init(cs: Int, ic: Character, ns: Int, oc: Character, di: Character){
        self.currentState = cs
        self.inputCharacter = ic
        self.newState = ns
        self.outputCharacter = oc
        self.direction = di
    }
    var description: String {
        return "{cs: \(currentState), ic: \(inputCharacter), ns: \(newState), oc: \(outputCharacter), di: \(direction)}"
    }
}
