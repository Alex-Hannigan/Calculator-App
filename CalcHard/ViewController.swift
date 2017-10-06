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
        // Append the digit to the digits currently in the display.
        if appendTheNextDigit {
            // Prevents multiple decimal points from being input.
            if sender.currentTitle! != "." || !calculatorScreen.text!.contains(".") {
                calculatorScreen.text = calculatorScreen.text! + sender.currentTitle!
            }
        }
        // Replace the digits currently in the display.
        else {
            if sender.currentTitle! == "." {
                calculatorScreen.text = "0\(sender.currentTitle!)"
            }
            else {
                calculatorScreen.text = sender.currentTitle!
            }
            appendTheNextDigit = true
        }
    }
    
    // Undo the last input of a digit by the user.
    @IBAction func undoLastDigitPress() {
        if appendTheNextDigit {
            if calculatorScreen.text!.characters.count > 1 {
                // Remove it from the string of digits in the screen or..
                calculatorScreen.text! = String(calculatorScreen.text!.characters.dropLast())
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
        calculatorBrain.setOperand(to: displayValue)
        calculatorBrain.performOperation(sender.currentTitle!)
        if let result = calculatorBrain.result {
            displayValue = result
            descriptionScreen.text = calculatorBrain.getDescription + "="
        }
        else if calculatorBrain.resultIsPending {
            descriptionScreen.text = calculatorBrain.getDescription + "..."
        }
        else {
            calculatorScreen.text = "0"
            descriptionScreen.text = "0"
        }
        appendTheNextDigit = false
    }
    
}

