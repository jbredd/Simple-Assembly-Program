//
//  File.swift
//  Simple Assembly Program
//
//  Created by Joshua Shen on 5/11/19.
//  Copyright © 2019 Joshua Shen. All rights reserved.
//

import Foundation


struct Tokenizer {
    static let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let digits = Array("0123456789")
    static let instructions = Support.splitStringIntoParts("halt clrr clrx clrm clrb movir movrr movrm movmr movxr movar movb addir addrr addmr addxr subir subrr submr subxr mulir mulrr mulmr mulxr divir divrr divmr divxr jmp sojz sojnz aojz aojnz cmpir cmprr cmpmr jmpn jmpz jmpp jsr ret push pop stackc outci outcr outcx outcb readi printi readc readln brk movrx movxx outs nop jmpne")
    
    static func tokenizeChunks(_ chunks: [String])->[Token]  {
        var toRet = [Token]()
        for c in chunks {
            toRet.append(tokenizeChunk(Array(c)))
        }
        return toRet
    }
    static func tokenizeChunk(_ chunk: [Character])-> Token {
        let firstChar = chunk[0]
        let lastChar = chunk.last!
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
                return Token(.ImmediateString, sValue: getString(chunk))
            }
        case "\\":
            if lastChar == "\\" && chunk.count == 11 && digits.contains(chunk[1]) && chunk[2] == " " && chunk[4] == " " && chunk[6] == " " && chunk[8] == " " && (chunk[9] == "r" || chunk[9] == "l"){
                var di = 0
                if chunk[9] == "r" {di = 1} else {di = -1}
                return Token(.ImmediateTuple, tValue: Tuple(cs: Int(String(chunk[1]))!, ic: chunk[3], ns: Int(String(chunk[5]))!, oc: chunk[7], di: di))
            }
        default: print("", terminator: "") //pragmatically does nothing
        }
        if isInstruction(chunk){
            return Token(.Instruction, sValue: getString(chunk))
        }
        if isRegister(chunk){
            return Token(.Register, sValue: getString(chunk))
        }
        if isLabel(chunk){
            return Token(.Label, sValue: getString(chunk))
        }
        if isLabelDefinition(chunk){
            return Token(.LabelDefinition, sValue: getString(chunk))
        }
        if isDirective(chunk){
            return Token(.Directive, sValue: getString(chunk))
        }
        if isImmediateInteger(chunk){
            let cInt = Array(chunk[1..<chunk.count])
            return Token(.ImmediateInteger, iValue: Int(getString(cInt)), sValue: getString(chunk))
        }
        return Token(.BadToken)
    }
    
    static func getString(_ chunk: [Character])-> String {
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
    
    static func isRegister(_ chunk: [Character])-> Bool {
        let regChars = ["r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9"]
        return regChars.contains(getString(chunk))
    }
    
    static func isLabel(_ chunk: [Character])-> Bool {
        if chunk.count == 0 {return false} //for isLabelDefinition call
        if !chars.contains(chunk[0]) {return false}
        for i in 1..<chunk.count {
            if !chars.contains(chunk[i]) && !digits.contains(chunk[i]) {return false}
        }
        return true
    }
    static func isLabelDefinition(_ chunk: [Character])-> Bool {
        return isLabel(Array(chunk[0..<chunk.count - 1])) && chunk.last! == ":"
    }
    static func isInstruction(_ chunk: [Character])-> Bool {
        return instructions.contains(String(chunk))
    }
    static func isDirective(_ chunk: [Character])-> Bool {
        let s = getString(chunk)
        return s == ".String" || s == ".Integer" || s == ".Tuple" || s == ".Start" || s == ".string" || s == ".integer" || s == ".tuple" || s == ".start" 
    }
    static func isImmediateInteger(_ chunk: [Character])-> Bool{
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


