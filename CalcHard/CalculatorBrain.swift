//
//  CalculatorBrain.swift
//  CalcHard
//
//  Created by Alex Hannigan on 2017/10/01.
//  Copyright © 2017年 Alex Hannigan. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var stack = [Element]()
    
    // All of the basic types of elements that can comprise our calculation.
    private enum Element {
        case variable(String)
        case operand(Double)
        case operation(String)
    }
    
    // All of the generic types of operation that can be performed.
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String,String) -> String)
        case equals
    }
    
    // All of the specific operations that can be performed (each is one of the above generic types).
    private let operations = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, { "√(\($0))" }),
        "±": Operation.unaryOperation({-$0}, { "-\($0)" }),
        "x²": Operation.unaryOperation({$0 * $0}, { "(\($0))²" }),
        "x³": Operation.unaryOperation({$0 * $0 * $0}, { "(\($0))³" }),
        "sin": Operation.unaryOperation(sin, { "sin(\($0))" }),
        "+": Operation.binaryOperation(+, { "\($0) + \($1)" }),
        "−": Operation.binaryOperation(-, { "\($0) - \($1)" }),
        "×": Operation.binaryOperation(*, { "\($0) × \($1)" }),
        "÷": Operation.binaryOperation(/, { "\($0) ÷ \($1)" }),
        "=": Operation.equals,
    ]
    
    // Stores the first operand in our accumulator, and appends it to our description.
    mutating func setOperand(to operand: Double) {
        stack.append(Element.operand(operand))
    }
    
    mutating func setOperand(to named: String) {
        stack.append(Element.variable(named))
    }
    
    // Perform the appropriate operation according to the mathematical symbol received.
    mutating func performOperation(_ mathematicalSymbol:String) {
        stack.append(Element.operation(mathematicalSymbol))
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator: (Double, String)?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        struct PendingBinaryOperation {
            let function: (Double,Double) -> Double
            let description: (String,String) -> String
            let firstOperand: (Double,String)
            
            func perform(with secondOperand: (Double,String)) -> (Double,String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        var result: Double? {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
        
        var description: String? {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            }
            else {
                return accumulator?.1
            }
        }
        
        for element in stack {
            switch element {
            case .operand(let value):
                accumulator = (value, "\(value)")
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                    case .unaryOperation(let function, let description):
                        if accumulator != nil {
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                        }
                    case .binaryOperation(let function, let description):
                        performPendingBinaryOperation()
                        if accumulator != nil {
                            pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            case .variable(let symbol):
                if let value = variables?[symbol] {
                    accumulator = (value, symbol)
                }
                else {
                    accumulator = (0, symbol)
                }
            }
        }
        
        return (result, pendingBinaryOperation != nil, description ?? "")
    }
    
}
