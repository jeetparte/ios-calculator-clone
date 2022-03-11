/*
 Demonstrates a single-step or immediate-execution calculator:
 each binary operation is executed as soon as the next operator is pressed,
 and therefore the order of operations in a mathematical expression is not taken into account.
 
 See https://en.wikipedia.org/wiki/Calculator_input_methods#Immediate_execution for details.
 */

public enum CalculatorError: Error {
    case invalidInput
}

public class SingleStepCalculator {
    public var firstOperand: Double! = 0.0 {
        didSet {
            precondition(firstOperand != nil, "Error: This property must not be set to nil.")
            self.currentOperand = \.firstOperand
        }
    }
    
    public var secondOperand: Double? {
        didSet {
            if secondOperand != nil {
                self.currentOperand = \.secondOperand
            }
        }
    }
    public var operation: Operation?
    
    private var currentOperand = \SingleStepCalculator.firstOperand
    
    /** The value of the operand which is currently most suitable for display.
        - Note: A return value of `nil` signifies ...
    */
    public var displayValue: Double? {
        return self[keyPath: currentOperand]
    }
    
    public init() {
    }
    
    /**
            - Precondition: *d* must one of the digits between 0 and 9.
     
            - Throws: `CalculatorError.invalidInput` if *d* is not a single-digit number between 0 and 9.
     */
    public func inputDigit(_ d: Int) throws {
        guard (0...9) ~= d else {
            throw CalculatorError.invalidInput
        }
        
        if operation != nil && secondOperand == nil {
            secondOperand = 0.0 // this sets it as the current operand as well
        }
        
        self[keyPath: currentOperand] = (self[keyPath: currentOperand] ?? 0) * 10 + Double(d)
    }
    
    public func inputDigits(_ digits: Int ...) throws {
        for d in digits {
            try inputDigit(d)
        }
    }
    
    public func inputNumber(_ n: Int) {
        self[keyPath: currentOperand] = Double(n)
    }
    
    public func inputOperation(_ op: Operation) {
        if self.operation == nil {
            self.operation = op
        } else {
            // there's a previous operation
            
            // if 2nd operand is not specified, replace previous operation
            if secondOperand == nil {
                self.operation = op
            }
            // if 2nd op. is specified, execute it
            // then queue this operation
            else {
                self.evaluate()
                self.operation = op
            }
        }
    }
    
    public func evaluate() {
        guard let operation = self.operation, let secondOperand = self.secondOperand  else {
            return
        }
        
        switch operation {
        case .multiply:
            firstOperand *= secondOperand
        case .divide:
            firstOperand /= secondOperand
        case .add:
            firstOperand += secondOperand
        case .subtract:
            firstOperand -= secondOperand
        }
        
        self.secondOperand = nil
        self.operation = nil
    }
    
    public func allClear() {
        firstOperand = 0.0
        secondOperand = nil
        operation = nil
        
        self.currentOperand = \.firstOperand
    }
    
    public enum Operation {
        case multiply
        case divide
        case add
        case subtract
    }
}

extension SingleStepCalculator: CustomStringConvertible {
    public var description: String {
        return "a: \(String(describing: firstOperand)) , b: \(String(describing: secondOperand)), operation: \(String(describing: operation))"
    }
}
