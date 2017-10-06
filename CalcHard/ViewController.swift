//
//  ViewController.swift
//  CalcHard
//
//  Created by Alex Hannigan on 2017/10/01.
//  Copyright © 2017年 Alex Hannigan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // This label displays the result of our calculation so far.
    @IBOutlet weak var calculatorScreen: UILabel!
    
    //This label displays the sequence of operands and operations used in our calculation so far.
    @IBOutlet weak var descriptionScreen: UILabel!
    
    // Returns 'true' if the next digit typed by the user should be appended
    // to the digits currently in the display, and 'false' if it should
    // replace them.
    private var appendTheNextDigit = false
    
    // Create an instance of our model (this project follows the MVC design pattern)
    private var calculatorBrain = CalculatorBrain()
    
    // Store the value assigned to the 'M' button by the user
    private var variables = Dictionary<String,Double>()
    
    // Sets and gets the value currently on the 'result' screen of our calculator,
    // converting to a String (from Int) to set, and converting to an Int (from String) to get.
    private var displayValue:Double {
        get {
            return Double(calculatorScreen.text!)!
        }
        set {
            calculatorScreen.text = String(newValue)
        }
    }
    
    // Sets the 'result' screen to the number currently being typed by the user.
    @IBAction func userInputToDisplay(_ sender: UIButton) {
        // Store the digit input by the user.
        let digit = sender.currentTitle!
        
        // If the user has already started entering a number...
        if appendTheNextDigit {
            // Store the text currently on the screen of the calculator.
            let calculatorScreenText = calculatorScreen.text!
            
            // Make sure the user doesn't input multiple decimal points.
            // i.e. we don't want, for example, "5.1.1.2"
            if digit != "." || !calculatorScreenText.contains(".") {
                calculatorScreen.text = calculatorScreenText + digit
            }
        }
        // If this is a new number the user has just started entering,
        // put that number on the display, making sure it reads nice.
        else {
            switch digit {
            case ".":
                calculatorScreen.text = "0."
            case "0":
                if calculatorScreen.text == "0" {
                    return
                }
                fallthrough
            default:
                calculatorScreen.text = digit
            }
        }
        appendTheNextDigit = true
    }
    
    // Undo the last input of a digit by the user.
    @IBAction func undoLastDigitPress() {
        if appendTheNextDigit {
            if calculatorScreen.text!.count > 1 {
                // Remove it from the string of digits in the screen or..
                calculatorScreen.text! = String(calculatorScreen.text!.dropLast())
            }
            else {
                // ...reset the screen to '0'.
                calculatorScreen.text! = "0"
                appendTheNextDigit = false
            }
        }
    }
    
    // Perform the operation selected by the user,
    // using the value currently on the calculator screen.
    // If the operation was binary, get ready to accept the second operand.
    // Otherwise, display the result on the screen.
    @IBAction func performOperation(_ sender: UIButton) {
        if appendTheNextDigit {
            calculatorBrain.setOperand(to: displayValue)
            appendTheNextDigit = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            calculatorBrain.performOperation(mathematicalSymbol)
        }
        displayResult()
    }
    
    private func displayResult() {
        let evaluated = calculatorBrain.evaluate(using: variables)
        
        if let result = evaluated.result {
            displayValue = result
        }
        
        if evaluated.description != "" {
            descriptionScreen.text = evaluated.description + (evaluated.isPending ? "..." : "=")
        }
        else {
            descriptionScreen.text = "0"
        }
    }
    
    @IBAction func storeToMemory(_ sender: UIButton) {
        variables["M"] = displayValue
        appendTheNextDigit = false
        displayResult()
    }
    
    @IBAction func callMemory(_ sender: UIButton) {
        calculatorBrain.setOperand(to: "M")
        appendTheNextDigit = false
        displayResult()
    }
    
    @IBAction func reset(_ sender: UIButton) {
        calculatorBrain = CalculatorBrain()
        calculatorScreen.text = "0"
        descriptionScreen.text = "0"
        appendTheNextDigit = false
        variables = [:]
    }
    
    
}

