/*
 Demonstrates a single-step or immediate-execution calculator:
 each binary operation is executed as soon as the next operator is pressed,
 and therefore the order of operations in a mathematical expression is not taken into account.
 
 See https://en.wikipedia.org/wiki/Calculator_input_methods#Immediate_execution for details.
 */

public class SingleStepCalculator {
    /// - Note: This property should never be `nil`. It is an optional only so that it can be accessed together with
    /// the optional secondOperand property using a common KeyPath.
    private var firstOperand: Double! = 0.0 {
        didSet {
            precondition(firstOperand != nil, "Error: This property must not be set to nil.")
            self.currentOperand = \.firstOperand
            
            self.noActionsSinceLastEvaluation = false
        }
    }
    
    private var secondOperand: Double? {
        didSet {
            if secondOperand != nil {
                self.currentOperand = \.secondOperand
            }
            self.noActionsSinceLastEvaluation = false
        }
    }
    
    // TODO: - rename to binaryOperation?
    public var operation: BinaryOperation? {
        didSet {
            self.noActionsSinceLastEvaluation = false
        }
    }
    
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
        
        // Any input after evaluation should be considered fresh input
        // and should override the result of the evaluation
        if noActionsSinceLastEvaluation {
            assert(self.currentOperand == \.firstOperand)
            assert(self.operation == nil)
            // clear the previous result
            firstOperand = 0.0
        }
        
        // when there's a queued operation, we redirect input to second operand
        if operation != nil && secondOperand == nil {
            secondOperand = 0.0 // this sets it as the current operand as well
        }
        
        let currentValue = self[keyPath: currentOperand]!
        let d = Double(d)
        self[keyPath: currentOperand] = currentValue * 10 + Double(signOf: currentValue, magnitudeOf: d)
    }
    
    public func inputDigits(_ digits: Int ...) throws {
        for d in digits {
            try inputDigit(d)
        }
    }
    
    /// - Warning: ... offers two numeric input modes: numbers can either be entered digit-by-digit or
    /// as an entire number at once (i.e. as a block). Input modes are offered for flexibility and a chosen mode should be used exclusively across a particular run of using the calculator.
    public func inputNumber(_ n: Int) {
        var n = n
        if self.pendingSignChange {
            assert(self.currentOperand == \.secondOperand)
            assert(self.secondOperand?.magnitude == .zero)
            
            n.negate()
            self.pendingSignChange = false
        }
        currentOperand = operation != nil ? \.secondOperand : \.firstOperand
        self[keyPath: currentOperand] = Double(n)
    }
    
    public func inputOperation(_ op: BinaryOperation) {
        if self.operation == nil {
            self.operation = op
        } else {
            // there's a previous operation
            
            // if 2nd operand is not specified, replace previous operation
            if secondOperand == nil {
                self.operation = op
            }
            // if 2nd op. is specified, execute the  previous operation,
            // then queue this operation
            else {
                self.evaluate()
                self.operation = op
            }
        }
    }
    
    private var pendingSignChange = false
    public func inputOperation(_ op: UnaryOperation) {
        if op == .signChange {
            // If we trigger a sign-change operation after a binary operation (e.g. +, -, *, /),
            // the sign change should apply on the (to-be-entered) second operand, not the first.
            if operation != nil && secondOperand == nil {
                self.secondOperand = 0.0 // this sets it as the current operand as well
                self.pendingSignChange = true
            }
            
            self[keyPath: currentOperand]?.negate()
        }
    }
    
    /// `true` if the last interaction with the calculator was an evaluation (`=`) operation and no actions have been performed since.
    private var noActionsSinceLastEvaluation = false
    @discardableResult public func evaluate() -> Double {
        defer {
            // IMPORTANT: re-evaluate defer statement usage if we do error handling
            noActionsSinceLastEvaluation = true
        }
        // if the operator or 2nd operand are not specified,
        // simply return the 1st operand as result
        guard let operation = self.operation, let secondOperand = self.secondOperand  else {
            self.secondOperand = nil
            self.operation = nil
            return self.firstOperand!
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
        default:
            // TODO: - handle other binary operations
            break
        }
        
        self.secondOperand = nil
        self.operation = nil
        
        return self.firstOperand!
    }
    
    public func allClear() {
        firstOperand = 0.0
        secondOperand = nil
        operation = nil
                
        self.currentOperand = \.firstOperand
    }
    
    public enum BinaryOperation: CaseIterable {
        case multiply
        case divide
        case add
        case subtract
        case power
        case powerReverseOperands // * should we implement this?
        case logToTheBase
    }
    
    public enum UnaryOperation {
        case signChange
    }
}

extension SingleStepCalculator: CustomStringConvertible {
    public var description: String {
        return "a: \(String(describing: firstOperand)) , b: \(String(describing: secondOperand)), operation: \(String(describing: operation))"
    }
}
