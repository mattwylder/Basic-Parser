//
//  From this video: https://www.youtube.com/watch?v=uQNkrV0F07Q
//
//  Created by Matthew Wylder on 12/16/22.
//

import Foundation

/*
 
 Simple language example:
 
 let fruit = "apples"
 let number = 5 + 5
 print number + " " + fruit
 
 output:
 10 apples
 */

/*
 Tokens we want
 keywords: let, print
 operators: +, =
 identifiers: [a-z][a-z0-9]*
 numbers: [0-9]+
 strings: "[^"]*" (doesn't handle escape)
*/
public enum Token {
    case assign
    case plus
    case identifier(String)
    case number(Double)
    case string(String)
    case `let`
    case print
}

public func tokenize(_ input: String) throws -> [Token] {
    var scalars = Substring(input).unicodeScalars
    var tokens: [Token] = []
    while let token = scalars.readToken() {
        tokens.append(token)
    }
    if !scalars.isEmpty {
        // throw LexerError.unrecognizedInput(String(scalars))
    }
    return tokens
}

extension Substring.UnicodeScalarView {
    mutating func readToken() -> Token? {
        self.skipWhitespace()
        return readOperator() ??
        readIdentifier() ??
        readNumber() ??
        readString()
    }
    
    mutating func skipWhitespace() {
        let whitespace = CharacterSet.whitespacesAndNewlines
        while let scalar = self.first, whitespace.contains(scalar) {
            self.removeFirst()
        }
    }
    
    mutating func readOperator() -> Token? {
        let start = self
        switch self.popFirst() {
        case "=":
            return Token.assign
        case "+":
            return Token.plus
        default:
            self = start
            return nil
        }
    }
    
    mutating func readIdentifier() -> Token? {
        guard let head = self.first, CharacterSet.letters.contains(head) else {
            return nil
        }
        var name = String(self.removeFirst())
        while let c = self.first, CharacterSet.alphanumerics.contains(c) {
            name.append(Character(self.removeFirst()))
        }
        
        switch name {
        case "let":
            return Token.let
        case "print":
            return Token.print
        default:
            return Token.identifier(name)
        }
    }
    
    /// Not given by the source video. Gotta figure this out out alone
    /// Base case: single digit. convert Character to Int or Double?
    /// expand from there - peek forward until the following character is not numeric
    /// if it is whitespace we return a Number token.
    /// if it is anything other than whitespace we return nil
    /// return with head pointing to first non-numeric character.
    ///
    /// study `readString()` below and rework it for numeric logic
    ///
    /// Only supports single digit integers
    mutating func readNumber() -> Token? {
        guard let head = self.first, CharacterSet.decimalDigits.contains(head) else {
            return nil
        }
        let start = self
        var string = ""
        while let scalar = self.popFirst() {
            guard CharacterSet.decimalDigits.contains(scalar) else {
                self = start
                return nil
            }
            string.append(Character(scalar))
        }
        guard let double = Double(string) else {
            self = start
            return nil
        }
        return Token.number(double)
    }
    
    mutating func readString() -> Token? {
        guard first == "\"" else { return nil }
        let start = self
        self.removeFirst()
        var string = "", escaped = false
        while let scalar = self.popFirst(){
            switch scalar {
            case "\"" where !escaped:
                return Token.string(string)
            case "\\" where !escaped:
                escaped = true
            default:
                string.append(Character(scalar))
                escaped = false
            }
        }
        self = start
        return nil
    }
}

do {
    let result = try tokenize("let foo = \"bar\"")
    print(result)
} catch {
    print(error)
}
