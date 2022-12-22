//
//  AST.swift
//  Parser
//
//  Created by Matthew Wylder on 12/21/22.
//

import Foundation

enum Statement {
    case declaration(variable: String, value: Expression)
    case `print`(Expression)
}

// indirect required for enums which contain their own type. forces pass by reference for Self
indirect enum Expression {
    case number(Double)
    case string(String)
    case variable(String)
    case addition(lhs: Expression, rhs: Expression)
}


func parse(_ input: String) throws -> [Statement] {
    var tokens = try ArraySlice(tokenize(input))
    var statements: [Statement] = []
    while let statement = tokens.readStatement() {
        statements.append(statement)
    }
    if let token = tokens.first { // If there are any left over
//        throw ParserError.unexpectedToken(token)
    }
    return statements
}


extension ArraySlice where Element == Token {
    mutating func readStatement() -> Statement? {
        return self.readDeclaration() ?? self.readPrintStatement()
    }
    
    mutating func readDeclaration() -> Statement? {
        return nil
    }
    
    mutating func readPrintStatement() -> Statement? {
        let start = self
        switch self.popFirst() {
        case .print:
            guard let value = self.readExpression() else {
                fallthrough
            }
            return Statement.print(value)
        default:
            self = start
            return nil
        }
    }
    
    mutating func readExpression() -> Expression? {
        guard let lhs = readOperand() else {
            return nil
        }
        
        /*
         // example code is written like this, but requires enum implements Equatable
        guard self.popFirst() is .plus let rhs ... else {
            return nil
        }
         */
        
        let start = self
        switch self.popFirst() {
        case .plus?:
            guard let rhs = readExpression() else {
                fallthrough
            }
            return Expression.addition(lhs: lhs, rhs: rhs)
        default:
            self = start
            return lhs
        }
    }
    
    mutating func readOperand() -> Expression? {
        let start = self
        
        switch self.popFirst() {
        case Token.identifier(let variable)?:
            return Expression.variable(variable)
        case Token.number(let double)?:
            return Expression.number(double)
        case Token.string(let string)?:
            return Expression.string(string)
        default:
            self = start
            return nil
        }
        
        
    }
}
