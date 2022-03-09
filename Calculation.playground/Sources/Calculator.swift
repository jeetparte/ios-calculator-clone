/*
 Demonstrates a single-step or immediate-execution calculator:
 each binary operation is executed as soon as the next operator is pressed,
 and therefore the order of operations in a mathematical expression is not taken into account.
 
 See https://en.wikipedia.org/wiki/Calculator_input_methods#Immediate_execution for details.
 */

public enum CalculatorError: Error {
    case invalidInput
}

public class Calculator {
    public var firstOperand: Double! = 0.0
    public var secondOperand: Double?
    public var operation: Operation?
    
    private var currentOperand = \Calculator.firstOperand
    
    public init() {
    }
    
    public func inputDigit(_ d: Int) throws {
        guard d < 10 else {
            throw CalculatorError.invalidInput
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
            self.currentOperand = \.secondOperand
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
                self.secondOperand = nil
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
    }
    
    public enum Operation {
        case multiply
        case divide
        case add
        case subtract
    }
}

extension Calculator: CustomStringConvertible {
    public var description: String {
        return "a: \(String(describing: firstOperand)) , b: \(String(describing: secondOperand)), operation: \(String(describing: operation))"
    }
}
