import XCTest
@testable import CalculatorCore

final class CalculatorCoreTests: XCTestCase {
    var calculator: SingleStepCalculator!
    
    // a config parameter to run tests a little differently
    static var which: Int = 0
    
    override class func setUp() {
        // retrieve arguments passed at launch
        let arg = UserDefaults.standard.integer(forKey: "which")
        assert(arg != 0)
        which = arg
        print("Setup test-case for choice = ", which)
    }
    
    
    /// Runs before every test method.
    override func setUp() {
        self.calculator = SingleStepCalculator()
    }
    
    /// Runs after every test method.
    override func tearDown() {
        self.calculator = nil
    }
    
    // MARK: - Utility methods
    private func newCalculator() {
        if CalculatorCoreTests.which.isEven {
            calculator?.allClear()
        } else {
            calculator = .init()
        }
    }
    
    private func getDisplayValue() -> Double {
        return CalculatorCoreTests.which.isEven ? calculator.evaluate() : calculator.displayValue!
    }
    
    enum InputMethod: Int {
        case digit = 1
        case number = 2
    }
    /// Inputs in either of the accepted ways: digit-by-digit or as a block.
    private func inputAnyMethod(_ number: Int) {
        let method = InputMethod(rawValue: Self.which) ?? .digit
        
        self.input(number, inputMethod: method)
    }
    
    private func input(_ number: Int, inputMethod method: InputMethod) {
        switch method {
        case .digit:
            number.digits.forEach { d in
                try! calculator.inputDigit(d)
            }
            if number.signum() == -1 {
                calculator.inputOperation(.signChange)
            }
        case .number:
            calculator.inputNumber(number)
        }
    }
    
    private func execute(_ tests: [XOperatorYResult], assertBlock: AssertBlock? = nil) {
        for test in tests {
            self.inputAnyMethod(test.a)
            calculator.inputOperation(test.op)
            self.inputAnyMethod(test.b)
            
            let actualResult = calculator.evaluate()
            if assertBlock != nil {
                assertBlock!(actualResult, test.expected)
            } else {
                if test.expected.isNaN {
                    XCTAssertTrue(actualResult.isNaN)
                } else {
                    XCTAssertEqual(actualResult, test.expected)
                }
            }
            
            // optionally clear for next test
            if CalculatorCoreTests.which.isEven {
                self.newCalculator()
            }
        }
    }
    
    //MARK: - Test utility methods
    func testInputMethods() {
        // Test that different input methods are identical
        let numbers = [12, -23, 456, 9999, 0, -9999, 6, 456]
        
        for number in numbers {
            self.input(number, inputMethod: .digit)
            let digitInput = getDisplayValue()
            self.newCalculator()
            self.input(number, inputMethod: .number)
            let numberInput = getDisplayValue()
            XCTAssertEqual(digitInput, numberInput)
            self.newCalculator()
        }
    }
    
    // MARK: - Tests
    
    // MARK: Input
    func testNumberInput() {
        // Numbers entered update the display value and evaluate to themselves.
        let numbers = [0, 1, 12, -12, 345, 5, -67, 890, 123_456_7890]
        
        for number in numbers {
            self.inputAnyMethod(number)
            XCTAssertEqual(calculator.displayValue!, Double(number))
            XCTAssertEqual(calculator.evaluate(), Double(number))
        }
    }
    
    func testDecimalInsertionDigits() throws {
        // If numbers are entered as digits then
        // the sequence of operations
        // '123 . 0456' should result in a decimal value of 123.0456
        
        try calculator.inputDigits(1, 2, 3)
        calculator.insertDecimalPoint()
        try calculator.inputDigits(0, 4, 5, 6)
        
        XCTAssertEqual(self.getDisplayValue(), 123.0456)
        self.newCalculator()
    }
    
    func testSignChangeAfterDecimalPoint() {
        
    }
    
    func testNegativeEntry() throws {
        // if we start at a negative number e.g. -0,
        // successively inputting digits should give us the same result
        // as if we'd started with a positive number,
        // but with a negative sign instead
        
        // e.g. if inputs: 0,1,2,3 --> 123,
        // then inputs: -0,1,2,3 --> -123
        
        let startingNumbers = [0, 40, 1]
        
        for startingNumber in startingNumbers {
            calculator.inputNumber(startingNumber)
            try calculator.inputDigits(1,2,3)
            let positiveResult = calculator.displayValue!
            
            // new calculator
            self.newCalculator()
            
            self.inputAnyMethod(startingNumber)
            calculator.inputOperation(.signChange)
            try calculator.inputDigits(1,2,3)
            let negativeResult = calculator.displayValue!
            
            XCTAssertEqual(-positiveResult, negativeResult)
        }
    }

    // MARK: Evaluation
    func testEvaluateIdentity() {
        // If we evaluate (hit '=') when no binary operation has been specified,
        // it should just return the first operand
        let testNumbers = [1, -2]
        
        for testNumber in testNumbers {
            self.inputAnyMethod(testNumber)
            XCTAssertEqual(Double(testNumber), calculator.evaluate())
        }
    }
    
    func testPartialEvaluation() throws {
        // The sequence of operations
        // a, op, =,
        // should evaluate to a.
        
        // and
        // the sequence of operations
        // a, op, =,b, =
        // should evaluate to b.
        
        let tests: [XOperatorY] = [
            (4, .multiply, 2),
            (-30, .subtract, 10),
            (9, .divide, -5),
            (19, .add, 13),
        ]
        
        for test in tests {
            self.inputAnyMethod(test.a)
            calculator.inputOperation(test.op)
            let result1 = calculator.evaluate()
            XCTAssertEqual(result1, Double(test.a))
            
            self.inputAnyMethod(test.b)
            let result2 = calculator.evaluate()
            XCTAssertEqual(result2, Double(test.b))
            
            self.newCalculator()
        }
    }
    
    func testInputAfterEvaluationDigits() throws {
        // Any input after evaluation should be considered fresh input
        // and should override the result of the evaluation.
                
        // trigger a simple evaluation
        // 1 + 2 = 3
        try calculator.inputDigit(1)
        calculator.inputOperation(.add)
        try calculator.inputDigit(2)
        guard calculator.evaluate() == 3.0 else {
            XCTFail("Failed test-case setup.")
            return
        }
        
        // Add new input and check if evaluation interfered with it
        let successiveInputs = [9, 8, 6, 6 ,5, 1, 2, 3]
        var expectedResult: Double? = nil
        for input in successiveInputs {
            try calculator.inputDigit(input)
        
            expectedResult = (expectedResult ?? 0) * 10 + Double(input)
            XCTAssertEqual(calculator.displayValue, expectedResult)
        }
        XCTAssertEqual(expectedResult, calculator.evaluate())
    }
    
    func testImplicitEvaluation() {
        // If an operator is entered, after an evalutable expression has been entered,
        // that expression is evaluated and made the first operand for the operator just entered.
        
        let tests: [(expression: XOperatorY, operator: Operator, rhs: Int, finalResult: Double)] = [
            ((2, .multiply, 3), .add, 1, finalResult: 7),
            ((5, .subtract, 2), .multiply, 3, finalResult: 9),
            ((10, .add, -3), .multiply, 7, finalResult: 49),
            ((144, .divide, 12), .divide, 3, finalResult: 4),
        ]
        
        for test in tests {
            let expr = test.expression
            self.inputAnyMethod(expr.a)
            calculator.inputOperation(expr.op)
            self.inputAnyMethod(expr.b)
            
            calculator.inputOperation(test.operator)
            self.inputAnyMethod(test.rhs)
            
            XCTAssertEqual(calculator.evaluate(), test.finalResult)
        }
    }
    
    func testOperatorOverriding() {
        // If an operator is entered just after the previous one,
        // it overrides it.
        
        let tests: [(a: Int, op1: Operator, op2: Operator, b: Int, result: Double)] = [
            (2, .multiply, .subtract, 2, result: 0),
            (2, .subtract, .multiply, 2, result: 4),
            (10, .add, .divide, 2, result: 5),
        ]
        
        for test in tests {
            self.inputAnyMethod(test.a)
            calculator.inputOperation(test.op1)
            calculator.inputOperation(test.op2)
            self.inputAnyMethod(test.b)
            XCTAssertEqual(calculator.evaluate(), test.result)
        }
    }
    
    // MARK: Display value
    func testInitialDisplayValue() {
        // The initial display value on a calculator must be zero.
        let calculator = SingleStepCalculator()
        XCTAssertEqual(calculator.displayValue, 0)
    }
    
    func testDisplayValue() {
        // The display value on the calculator must change as expected after every input.
        
        let tests: [XOperatorYResult] = [
            (123, .add, -23, expected: 100),
            (-23, .multiply, 2, expected: -46),
            (0, .subtract, -5, expected: 5),
            (10, .divide, -2, expected: -5)
        ]
        
        for test in tests {
            let a = Double(test.a)
            let b = Double(test.b)
            let result = Double(test.expected)
            
            // on initial input, display value = first operand
            self.inputAnyMethod(test.a)
            XCTAssertEqual(calculator.displayValue!, a)
            // after operation input, display value = first operand
            calculator.inputOperation(test.op)
            XCTAssertEqual(calculator.displayValue!, a)
            // on input after an operator, display value = second operand
            self.inputAnyMethod(test.b)
            XCTAssertEqual(calculator.displayValue!, b)
            // after evaluation, display value = operator(1st operand, 2nd operand)
            calculator.evaluate()
            XCTAssertEqual(calculator.displayValue!, result)
        }
    }
    
    func testDisplayValueDigits() throws {
        // When numbers are entered digit-by-digit, the display value must update every digit.

        // expression: '123 + 26'
        try calculator.inputDigit(1)
        XCTAssertEqual(calculator.displayValue!, 1)
        try calculator.inputDigit(2)
        XCTAssertEqual(calculator.displayValue!, 12)
        try calculator.inputDigit(3)
        XCTAssertEqual(calculator.displayValue!, 123)
        
        calculator.inputOperation(.add)
        
        try calculator.inputDigit(2)
        XCTAssertEqual(calculator.displayValue!, 2)
        try calculator.inputDigit(6)
        XCTAssertEqual(calculator.displayValue!, 26)
    }
    
    // MARK: Sign change
    func testSignChange() {
        // A sign change operation flips the sign of the value it operates on.
        
        // signChange(a) -> -a
        // signChange(-a) -> a
        
        let numbers = [0, 1, 10, 123, -123]
        // TODO: check floating point cases - +inf, -inf, pi
        
        for number in numbers {
            self.inputAnyMethod(number)
            calculator.inputOperation(.signChange)
            let negativeValue = getDisplayValue()
            XCTAssertEqual(Double(-number), negativeValue)
            
            calculator.inputOperation(.signChange)
            let postiveValue = getDisplayValue()
            XCTAssertEqual(Double(number), postiveValue)
            
            self.newCalculator()
        }
    }
    
    func testSignChangeBeforeFirstOperand() {
        // If we input a sign change operation before entering the first operand,
        // it should apply to it correctly.
        
        // 'signChange a' or 'signChange a =' should equal -a
        let tests = [1, 0, -0, -999]
        
        for a in tests {
            calculator.inputOperation(.signChange)
            self.inputAnyMethod(a)
            XCTAssertEqual(calculator.displayValue, -Double(a))
            XCTAssertEqual(calculator.evaluate(), -Double(a))
            
            self.newCalculator()
        }
    }
    
    func testSignChangeAfterFirstOperand() {
        // If we input a sign change operation after entering the first operand,
        // it should apply to it correctly.
        
        // 'a signChange' or 'a signChange =' should equal -a
        let tests = [1, 0, -0, -999]
        
        for a in tests {
            self.inputAnyMethod(a)
            calculator.inputOperation(.signChange)
            XCTAssertEqual(calculator.displayValue, -Double(a))
            XCTAssertEqual(calculator.evaluate(), -Double(a))
            
            self.newCalculator()
        }
    }
        
    func testSignChangeBeforeSecondOperand() throws {
        // If we trigger a sign-change operation after a binary operation (e.g. +, -, *, /),
        // but before the second operand,
        // the sign change should apply on the second operand, not the first.
        //
        // a, op, signChange, b = a op signChange(b) ≠ signChange(a) op b
        
        // 1 + signChange 3 = 1 + (-3) ≠ (-1) + 3
        self.inputAnyMethod(1)
        calculator.inputOperation(.add)
        calculator.inputOperation(.signChange)
        self.inputAnyMethod(3)
        // 2nd operand should now display as -3
        XCTAssertEqual(calculator.displayValue!, -3.0)
        let result = calculator.evaluate()
        XCTAssertEqual(result, -2.0)
    }
    
    func testSignChangeAfterSecondOperand() throws {
        // If we input a sign change operation after entering the second operand,
        // it should apply to it correctly.
        
        // After entering 'a op b',
        // sign change should apply on b
        // i.e. 'a op b signChange' = 'a op -b'
        
        let tests: [XOperatorY] = [
            (1, .add, 10), (1, .subtract, 10), (1, .multiply, 10), (1, .divide, 10), // ...
            (2, .add, 0), (2, .subtract, 0), (2, .multiply, 0), (2, .divide, 0), // ...
            (3, .add, -8), (3, .subtract, -8), (3, .multiply, -8), (3, .divide, -8), // ...
        ]
        
        for test in tests {
            self.inputAnyMethod(test.a)
            calculator.inputOperation(test.op)
            self.inputAnyMethod(test.b)
            calculator.inputOperation(.signChange)
            XCTAssertEqual(-Double(test.b), calculator.displayValue!)
            
            self.newCalculator()
        }
    }
    
    // MARK: Basic operations
    func testAllClear() {
        // An all-clear operation should reset the calculator to its initial state.
        
        // First, exercise the calculator
        // expression: '12 * 3 / 2 + signChange 7 * 5'
        self.inputAnyMethod(12)
        calculator.inputOperation(.multiply)
        self.inputAnyMethod(3)
        calculator.inputOperation(.divide)
        self.inputAnyMethod(2)
        calculator.inputOperation(.add)
        calculator.inputOperation(.signChange)
        self.inputAnyMethod(7)
        calculator.inputOperation(.multiply)
        self.inputAnyMethod(5)
        
        // set up a comparison
        let newCalculator = SingleStepCalculator()
        // verify that the state has changed
        XCTAssertNotEqual(calculator, newCalculator)
        // then, clear it
        calculator.allClear() // *
        // and compare its state to that a new calculator.
        XCTAssertEqual(calculator, newCalculator)
    }
    
    func testAddition() throws {
        let tests: [XOperatorYResult] = [
            (1, .add, 5, expected: 6),
            (357, .add, -5, expected: 352),
            (-1, .add, 5, expected: 4),
            (0, .add, 1435, expected: 1435),
            (1, .add, 0, expected: 1),
        ]
        
        self.execute(tests)
    }
    
    func testRepeatedAddition() throws {
        // 1 + 2 + ... + 10 = 55
        let expectedResult = Double(55)
        
        calculator.inputNumber(1)
        for i in 2...10 {
            calculator.inputOperation(.add)
            calculator.inputNumber(i)
        }
        let actualResult = calculator.evaluate()
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testRepeatedAdditionDigits() throws {
        // 1 + 2 + ... + 10 = 55
        let expectedResult = Double(55)
        
        for i in 1...9 {
            try calculator.inputDigit(i)
            calculator.inputOperation(.add)
        }
        try calculator.inputDigits(1,0)
        let actualResult = calculator.evaluate()
        XCTAssertEqual(actualResult, expectedResult)
        
        // a simpler test
        // 1 + 2 + 3 = 6
        do {
            let expectedResult = Double(6)
            
            for i in 1...2 {
                try calculator.inputDigit(i)
                calculator.inputOperation(.add)
            }
            try calculator.inputDigits(3)
            let actualResult = calculator.evaluate()
            XCTAssertEqual(actualResult, expectedResult)
        }
    }
    
    func testSubtraction() throws {
        let tests: [XOperatorYResult] = [
            (1, .subtract, 3, expected: -2),
            (1, .subtract, -100, expected: 101),
            (-1, .subtract, -100, expected: 99),
            (-50, .subtract, 40, expected: -90),
            (23, .subtract, 0, expected: 23),
            (0, .subtract, -9, expected: 9)
        ]
        
        self.execute(tests)
    }
        
    func testMultiplication() {
        let tests: [XOperatorYResult] = [
            (12, .multiply, 12, expected: 144),
            (10, .multiply, -9, expected: -90),
            (-9, .multiply, 10, expected: -90),
            (-4, .multiply, -4, expected: 16),
            (-4, .multiply, 20, expected: -80),
            (12, .multiply, 0, expected: 0),
            (12, .multiply, 1, expected: 12),
        ]
        
        self.execute(tests)
    }
    
    func testDivision() {
        let tests: [XOperatorYResult]  = [
            (100, .divide, 5, expected: 20), //    Integer result
            
            (5, .divide, 0, expected: .infinity), // divide by zero
            (-5, .divide, 0, expected: -.infinity),
            (0, .divide, 0, expected: .nan),
            
            (100, .divide, -2, expected: -50), //    Negative y
            (-1, .divide, 5, expected: -0.2), //    Negative x
            (1, .divide, 10, expected: 0.1), //    Fractional result
            // TODO: support fractional operand
//            (1, .divide, 0.1, expected: 10), //    Fractional y
        ]
        
        self.execute(tests)
    }
}
