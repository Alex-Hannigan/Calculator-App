//
//  CalculatorBrain.swift
//  CalcHard
//
//  Created by Alex Hannigan on 2017/10/01.
//  Copyright © 2017年 Alex Hannigan. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    // The result of our calculation so far.
    private var accumulator: Double?
    
    // The sequence of operands and operations used in our calculation so far.
    private var description = ""
    
    // Returns whether we are currently in the middle of a binary operation.
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    // All of the generic types of operation that can be performed.
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case resetEverything
    }
    
    // All of the specific operations that can be performed (each is one of the above generic types).
    private var operations = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "±": Operation.unaryOperation({-$0}),
        "x²": Operation.unaryOperation({$0 * $0}),
        "x³": Operation.unaryOperation({$0 * $0 * $0}),
        "sin": Operation.unaryOperation(sin),
        "cos": Operation.unaryOperation(cos),
        "tan": Operation.unaryOperation(tan),
        "+": Operation.binaryOperation(+),
        "−": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.equals,
        "C": Operation.resetEverything
    ]
    
    // Stores the first operand in our accumulator, and appends it to our description.
    mutating func setOperand(to operand: Double) {
        accumulator = operand
        if resultIsPending {
            description += String(operand)
        }
        else if description == "" {
            description = String(operand)
        }
    }
    
    // Perform the appropriate operation according to the mathematical symbol received.
    mutating func performOperation(_ mathematicalSymbol:String) {
        if let symbol = operations[mathematicalSymbol] {
            switch symbol {
            case .constant(let value):
                accumulator = value
                description = mathematicalSymbol
            case .unaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        switch mathematicalSymbol {
                        case "x²":
                            description += "(\(accumulator!))²"
                        case "x³":
                            description += "(\(accumulator!))³"
                        default:
                            description += "\(mathematicalSymbol)(\(accumulator!))"
                        }
                        accumulator = function(accumulator!)
                        performPendingBinaryOperation()
                    }
                    else {
                        switch mathematicalSymbol {
                        case "x²":
                            description = "(\(description))²"
                        case "x³":
                            description = "(\(description))³"
                        default:
                            description = "\(mathematicalSymbol)(\(description))"
                        }
                        accumulator = function(accumulator!)
                    }
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    if pendingBinaryOperation != nil {
                        performPendingBinaryOperation()
                    }
                    pendingBinaryOperation = PendingBinaryOperation(firstOperand: accumulator!, function: function)
                    accumulator = nil
                    description += mathematicalSymbol
                }
            case .equals:
                if accumulator != nil && pendingBinaryOperation != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = nil
                }
            case .resetEverything:
                accumulator = nil
                description = ""
                pendingBinaryOperation = nil
            }
        }
    }
    
    // If we are currently in the middle of a binary operation, this var will hold the first operand
    // and the appropriate function to be performed.
    // If not, this will be 'nil'.
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let firstOperand: Double
        let function: (Double,Double) -> Double
        
        func perform(with secondOperand:Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    // Complete our pending binary operation and store the result in our accumulator.
    mutating private func performPendingBinaryOperation() {
        accumulator = pendingBinaryOperation?.perform(with: accumulator!)
    }
    
    // A read-only var which returns the result of our calculation so far.
    var result:Double? {
        return accumulator
    }
    
    // A read-only var which returns the sequence of operands and operations used in our calculation so far.
    var getDescription: String {
        return description
    }
}
