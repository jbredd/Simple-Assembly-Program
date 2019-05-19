//
//  Tokenizer.swift
//  PartialVM
//
//  Created by Nicholas Hatzis-Schoch on 5/12/19.
//  Copyright © 2019 Slick Games. All rights reserved.
//

import Foundation

struct Tokenizer {
    let chars = Set(Array("abcdefghijklmnopqrstuvwxyz"))
    let digits = Set(Array("0123456789"))
    var tokens = [Token]()
    
    mutating func tokenizeChunks(_ chunks: [String])->[Token]  {
        var toRet = [Token]()
        for c in chunks {
            toRet.append(tokenizeChunk(Array(c)))
        }
        return toRet
    }
    func tokenizeChunk(_ chunk: [Character])-> Token {
        let firstChar = chunk[0]
        let lastChar = chunk.last!
        var token = Token(.BadToken)
        /*
         check if it is instruction
         check if it is register
         check if it is label
         check if it is label definition
         
         check if it is an immediate or a directive
         */
        switch firstChar {
        case "\"":
            if lastChar == "\"" && chunk.count >= 2 {
                token = Token(.ImmediateString, sValue: getString(chunk))
            }
        case "\\":
            if lastChar == "\\" && chunk.count == 11 && digits.contains(chunk[1]) && digits.contains(chunk[5]) && chunk[2] == " " && chunk[4] == " " && chunk[6] == " " && chunk[8] == " " && (chunk[9] == "r" || chunk[9] == "l"){
                if chunk[9] == "r" {let di = 1} else {let di = -1}
                token = Token(.ImmediateTuple, tValue: Tuple(cs: Int(String(chunk[1]))!, ic: chunk[3], ns: Int(String(chunk[5]))!, oc: chunk[7], di: di))
            }
        default:
            token =  Token(.BadToken)
        }
        if isLabel(chunk){
            token = Token(.Label, sValue: getString(chunk))
        }
        if isRegister(chunk){
            token = Token(.Register, sValue: getString(chunk))
        }
        if isInstruction(chunk){
            token = Token(.Instruction, sValue: getString(chunk))
        }
        if isLabelDefinition(chunk){
            token = Token(.LabelDefinition, sValue: getString(chunk))
        }
        if isDirective(chunk){
            token = Token(.Directive, sValue: getString(chunk))
        }
        if isImmediateInteger(chunk){
            let cInt = Array(chunk[1..<chunk.count])
            token = Token(.ImmediateInteger, iValue: Int(getString(cInt)), sValue: getString(chunk))
        }
        return token
    }
    
    func getString(_ chunk: [Character])-> String {
        var toRet = ""
        if (chunk[0] == "\"" || chunk[0] == "\\") && chunk.last! == chunk[0]{
            for i in 1...chunk.count - 2 {
                toRet += String(chunk[i])
            }
        }
        else{
            toRet = String(chunk)
        }
        return toRet
    }
    
    func isRegister(_ chunk: [Character])-> Bool {
        let regChars = ["r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9"]
        return regChars.contains(getString(chunk))
    }
    
    func isLabel(_ chunk: [Character])-> Bool {
        if !chars.contains(chunk[0]) {return false}
        for i in 1..<chunk.count {
            if !chars.contains(chunk[i]) && !digits.contains(chunk[i]) {return false}
        }
        return true
    }
    func isLabelDefinition(_ chunk: [Character])-> Bool {
        return isLabel(Array(chunk[0..<chunk.count - 1])) && chunk.last! == ":"
    }
    func isInstruction(_ chunk: [Character])-> Bool {
        var instructions = [String]()
        for i in Instruction.allCases {
            instructions.append(i.description)
        }
        return instructions.contains(String(chunk))
    }
    func isDirective(_ chunk: [Character])-> Bool {
        let chunkStr = getString(chunk)
        return chunkStr == ".string" || chunkStr == ".integer" || chunkStr == ".tuple" || chunkStr == ".start"
    }
    func isImmediateInteger(_ chunk: [Character])-> Bool{
        if chunk[0] != "#"{return false}
        else{
            for c in chunk[1..<chunk.count]{
                if !digits.contains(c){
                    return false
                }
            }
            return true
        }
    }
}
