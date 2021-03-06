/*
 Demonstrates a single-step or immediate-execution calculator:
 each binary operation is executed as soon as the next operator is pressed,
 and therefore the order of operations in a mathematical expression is not taken into account.
 
 See https://en.wikipedia.org/wiki/Calculator_input_methods#Immediate_execution for details.
 */

import Foundation

public class SingleStepCalculator {
    /// - Note: This property should never be `nil`. It is an optional only so that it can be accessed together with
    /// the optional secondOperand property using a common KeyPath.
    private var firstOperand: CalculatorNumber! = CalculatorNumber(0.0) {
        didSet {
            precondition(firstOperand != nil, "Error: This property must not be set to nil.")
            self.currentOperand = \.firstOperand
            
            self.recordInput()
            
            /* TODO: - We may want to may want allow clients to track changes to the hasInsertedDecimal property so that they can modify the presentation of the calculator's display value to show the decimal point when it is inserted.
             */
        }
    }
    
    private var secondOperand: CalculatorNumber? {
        didSet {
            if secondOperand != nil {
                self.currentOperand = \.secondOperand
            }
            self.recordInput()
        }
    }
    
    public var operation: BinaryOperation? {
        didSet {
            self.recordInput()
        }
    }
    
    private var currentOperand = \SingleStepCalculator.firstOperand
    private var isDirty = false
    /// For number input, we need to track any sign changes and apply them at the time of input.
    private var pendingSignChange = false
    
    private var memory: Double = 0
    
    // MARK: - Public API
    /** The value of the operand which is currently most suitable for display.
        - Note: A return value of `nil` signifies ...
    */
    public var displayValue: Double? {
        return self[keyPath: currentOperand]?.value
    }
    
    public var trignometryInputMode: TrignometryInputMode = .degrees {
        didSet {
            print("mode = ", self.trignometryInputMode)
        }
    }
    
    public enum TrignometryInputMode: CaseIterable {
        case degrees
        case radians
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
        if self.clearOnNextInput {
            self.clearCurrent()
        }
        
        // when there's a queued operation, we redirect input to second operand
        if self.followsBinaryOperator() {
            self.redirectInputToSecondOperand()
        }
        
        if self[keyPath: currentOperand]!.hasInsertedDecimal {
            // this is a decimal number,
            // input must go into the fractional part
            self[keyPath: currentOperand]!.fractionalPart += "\(d)"
        } else {
            // this in not a decimal number (so far),
            // input must go into the integral part
            let currentValue = self[keyPath: currentOperand]!.value
            let d = Double(d)
            let newValue = currentValue * 10 + Double(signOf: currentValue, magnitudeOf: d)
            self[keyPath: currentOperand]!.setValue(newValue)
        }
    }
    
    public func inputDigits(_ digits: Int ...) throws {
        for d in digits {
            try inputDigit(d)
        }
    }
    
    // This applies only to digit input mode. TODO: document it.
    public func insertDecimalPoint() {
        // clear previous evaluation, if present
        if self.clearOnNextInput {
            self.clearCurrent()
        }
        
        // initialize operand, if required
        if self.followsBinaryOperator() {
            self.redirectInputToSecondOperand()
        }
        
        // modify state so that any digit inputs that follow
        // go into the fractional part
        self[keyPath: currentOperand]!.hasInsertedDecimal = true
    }
    
    /// - Warning: The calculator offers two numeric input modes: numbers can either be entered digit-by-digit or
    /// as an entire number at once (i.e. as a block). Input modes are offered for flexibility and a chosen mode should be used exclusively across a particular run of using the calculator.
    public func inputNumber(_ n: Double) {
        self.setCurrentOperand(n, pendingSignChange: self.pendingSignChange)
    }
    
    public func input(_ special: SpecialInput) {
        let value: Double = {
            switch special {
            case .eulersConstant:
                return .exp(1)
            case .pi:
                return .pi
            case .randomNumber:
                return Double.random(in: 0...1)
            }
        }()
        
        self.setCurrentOperand(value, pendingSignChange: self.pendingSignChange)
        self.clearOnNextInput = true
    }
    
    public func inputOperation(_ op: BinaryOperation) throws {
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
                try self.evaluate()
                self.operation = op
            }
        }
    }
    
    public func inputOperation(_ op: UnaryOperation) {
        if op == .signChange {
            self.doSignChange()
            return
        }
                
        if let trigFunction = trigFunctions[op] {
            try! self.doUnary {
                // handle degrees or radians input
                var currentValue = $0
                if self.trignometryInputMode == .degrees {
                    currentValue = convertToRadians($0)
                }
                return trigFunction(currentValue)
            }
        } else {
            let function = unaryFunctions[op]!
            try! self.doUnary(function) //FIXME: propagate/communicate this error to the app somehow
        }
    }
    
    public func input(_ configuration: Configuration) {
        if configuration == .toggleDegreesOrRadians {
            self.trignometryInputMode = (self.trignometryInputMode == .radians) ? .degrees : .radians
        }
    }
    
    @discardableResult
    public func evaluate() throws -> Double {
        defer {
            // IMPORTANT: re-evaluate defer statement usage if we do error handling
            clearOnNextInput = true
        }
        // if the operator or 2nd operand are not specified,
        // simply return the 1st operand as result
        guard let operation = self.operation, let secondOperand = self.secondOperand  else {
            self.secondOperand = nil
            self.operation = nil
            return self.firstOperand!.value
        }
        
        // apply operation
        let function = binaryFunctions[operation]!
        guard let result = function(self.firstOperand.value, secondOperand.value) else { throw CalculatorError.calculationError }
        self.firstOperand = CalculatorNumber(result)
        
        self.secondOperand = nil
        self.operation = nil
        
        return self.firstOperand!.value
    }
        
    /// - Returns: The value of the memory register after performing the given memory function.
    public func performMemoryFunction(_ f: MemoryFunction) {
        switch f {
        case .clear:
            self.memory = 0.0
        case .add, .subtract:
            guard var current = self[keyPath: currentOperand]?.value else { break }
            if currentOperand == \.firstOperand {
                // if an operator has been input, do nothing
                guard operation == nil else { break }
                if f == .subtract { current = -current }
                self.memory += current
                self.clearOnNextInput = true
            } else if currentOperand == \.secondOperand {
                if f == .subtract { current = -current }
                self.memory += current
                self.clearOnNextInput = true
            }
        }
    }
    
    @discardableResult
    public func recallMemory() -> Double {
        // Replace current operand with memory register value
        if self.followsBinaryOperator() {
            self.currentOperand = \.secondOperand
        }
        self[keyPath: currentOperand] = CalculatorNumber(self.memory)
        self.clearOnNextInput = true
        
        return self.memory
    }
    
    public func allClear() {
        // reset to initial state
        self.firstOperand.reset()
        self.secondOperand = nil
        self.currentOperand = \.firstOperand

        self.operation = nil

        self.isDirty = false
        self.pendingSignChange = false
        self.clearOnNextInput = false
        
        // TODO: what about memory register?
    }        
    
    // MARK: -
    
    private func setCurrentOperand(_ value: Double, pendingSignChange: Bool) {
        var value = value
        if self.pendingSignChange {
            // we should only have a non-applied sign change on 'fresh' operands
            // i.e. sign change applied before any input
            assert(self[keyPath: currentOperand]?.magnitude == .zero)
            
            value.negate()
            self.pendingSignChange = false
        }
        currentOperand = operation != nil ? \.secondOperand : \.firstOperand
        self[keyPath: currentOperand] = CalculatorNumber(value)
    }
    
    private func recordInput() {
        self.clearOnNextInput = false
        self.isDirty = true
    }
    
    private func followsBinaryOperator() -> Bool {
        // true if a binary operation has been entered
        // but the input of the second operand has not begun
        return operation != nil && secondOperand == nil
    }
    
    private func redirectInputToSecondOperand() {
        self.secondOperand = CalculatorNumber(0.0) // this sets it as the current operand as well
    }
    
    private func clearCurrent() {
        self[keyPath: currentOperand]?.reset()
    }
    
    private func doSignChange() {
        // If sign change is entered before first operand,
        // queue it for later.
        if !self.isDirty {
            self.pendingSignChange = true
        }
        
        // If we trigger a sign-change operation after a binary operation (e.g. +, -, *, /),
        // the sign change should apply on the (to-be-entered) second operand, not the first.
        if self.followsBinaryOperator() {
            assert(self.isDirty)
            self.redirectInputToSecondOperand()
            self.pendingSignChange = true
        }
        
        self[keyPath: currentOperand]?.negate()
    }
    
    private func doUnary(_ transform: (Double) -> Double?) throws {
        guard let currentValue = self[keyPath: currentOperand]?.value else { return }
        
        if currentOperand == \.firstOperand {
            // do not change first operand after the operator has been input
            guard operation == nil else { return }
            try apply()
        } else if currentOperand == \.secondOperand {
            try apply()
        }
                
        func apply() throws {
            guard let newValue = transform(currentValue) else {
                throw CalculatorError.calculationError
            }
            
            self[keyPath: currentOperand]!.setValue(newValue)
            self.clearOnNextInput = true
        }
    }
    
    /// `true` if the next input received should clear the contents of the current operand.
    private var clearOnNextInput = false
}

extension SingleStepCalculator: CustomStringConvertible {
    public var description: String {
        return "a: \(String(describing: firstOperand)) , b: \(String(describing: secondOperand)), operation: \(String(describing: operation))"
    }
}

extension SingleStepCalculator: Equatable {
    public static func == (lhs: SingleStepCalculator, rhs: SingleStepCalculator) -> Bool {
        // A calculator is entirely state driven,
        // so two calculators are equal if they have the same state.
        return lhs.firstOperand == rhs.firstOperand
            && lhs.secondOperand == rhs.secondOperand
            && lhs.operation == rhs.operation
            && lhs.currentOperand == rhs.currentOperand
            && lhs.isDirty == rhs.isDirty
            && lhs.pendingSignChange == rhs.pendingSignChange
            && lhs.clearOnNextInput == rhs.clearOnNextInput
        
        // FIXME: This doesn't check for memory register atm.
    }
}
