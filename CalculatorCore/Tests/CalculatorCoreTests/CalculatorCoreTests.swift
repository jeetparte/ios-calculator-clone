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
    
    
    override func setUp() {
        self.calculator = SingleStepCalculator()
    }
    
    override func tearDown() {
        self.calculator = nil
    }
    
    // MARK: - Utility methods
    private func newCalculator() {
        if CalculatorCoreTests.which.isMultiple(of: 2) {
            calculator?.allClear()
        } else {
            calculator = .init()
        }
    }
    
    /* A note on the *any* functions below -
     They serve as generator functions for any inputs that are irrrelevant to the test result.
     See https://softwareengineering.stackexchange.com/a/429622/342114.
     
     Ideally, we'd want to record the seed value as part of the test results so that we can reproduce them.
     */
    private func inputAnyNumber(in range: ClosedRange<Int>? = nil) {
        let range = range ?? -999_999_999...999_999_999
        calculator.inputNumber(Int.random(in: range))
    }
    
    private func inputAnyDigits(numberOfDigits n: Int? = nil) throws {
        let n = n ?? Int.random(in: 1...10)
        let count = (1...n)
        
        for _ in count {
            let d = Int.random(in: 0...9)
            try calculator.inputDigit(d)
        }
    }
    
    private func inputAnyBinaryOperation() {
        calculator.inputOperation(.allCases.randomElement()!)
    }
    // MARK: - Tests
    func testNegativeEntry() throws {
        // if we start at a negative number e.g. -0,
        // successively inputting digits should give us the same result
        // as if we'd started with a positive number but with a negative sign
        
        // e.g. if inputs: 0,1,2,3 --> 123,
        // then inputs: -0,1,2,3 --> -123
        
        let startingNumbers = [0, 40, 1]
        
        for startingNumber in startingNumbers {
            calculator.inputNumber(startingNumber)
            try calculator.inputDigits(1,2,3)
            let positiveResult = calculator.displayValue!
            
            // new calculator
            self.newCalculator()
            
            calculator.inputNumber(startingNumber)
            calculator.inputOperation(.signChange)
            try calculator.inputDigits(1,2,3)
            let negativeResult = calculator.displayValue!
            
            XCTAssertEqual(-positiveResult, negativeResult)
        }
    }
    
    func testEvaluateIdentity() {
        // If we evaluate (hit '=') when no binary operation has been specified,
        // it should just return the first operand
        let testNumbers = [1, -2]
        
        for testNumber in testNumbers {
            calculator.inputNumber(testNumber)
            XCTAssertEqual(Double(testNumber), calculator.evaluate())
        }
    }
    
    func testEvaluateSequenceDigits() throws {
        // The sequence of operations
        // a, op, =, b, =
        // should evaluate to b.
        
        let tests: [(a: Int, op: SingleStepCalculator.BinaryOperation, b: Int)] = [
            (4, .multiply, 2),
            (3, .subtract, 1),
            (9, .divide, 5),
            (7, .add, 3),
        ]
        
        for test in tests {
            try calculator.inputDigit(test.a)
            calculator.inputOperation(test.op)
            calculator.evaluate()
            try calculator.inputDigit(test.b)
            let result = calculator.evaluate()
            XCTAssertEqual(result, Double(test.b))
            
            self.newCalculator()
        }
    }
    
    func testEvaluateSequenceNumbers() {
        // The sequence of operations
        // a, op, =, b, =
        // should evaluate to b.
        
        let tests: [(a: Int, op: SingleStepCalculator.BinaryOperation, b: Int)] = [
            (40, .multiply, 20),
            (30, .subtract, 10),
            (10, .divide, 7),
            (19, .add, 13),
        ]
        
        for test in tests {
            calculator.inputNumber(test.a)
            calculator.inputOperation(test.op)
            calculator.evaluate()
            calculator.inputNumber(test.b)
            let result = calculator.evaluate()
            XCTAssertEqual(result, Double(test.b))
            
            self.newCalculator()
        }
    }
    
    func testDisplayValue() {
        // TODO:
    }
    
    func testSignChange() {
        // signChange(a) -> -a
        // signChange(-a) -> a
        
        let numbers = [0, 1, 10, 123]
        
        for number in numbers {
            calculator.inputNumber(number)
            calculator.inputOperation(.signChange)
            let negativeValue = getDisplayValue()
            XCTAssertEqual(Double(-number), negativeValue)
            
            calculator.inputOperation(.signChange)
            let postiveValue = getDisplayValue()
            XCTAssertEqual(Double(number), postiveValue)
        }
        
        func getDisplayValue() -> Double {
            return CalculatorCoreTests.which.isMultiple(of: 2) ? calculator.evaluate() : calculator.displayValue!
        }
    }
    
    func testSignChangeAfterBinaryOperationDigits() throws {
        // If we trigger a sign-change operation after a binary operation (e.g. +, -, *, /),
        // the sign change should apply on the second operand, not the first.
        //
        // a, op, signChange, b = a op signChange(b) ≠ signChange(a) op b
        
        // 1 + signChange 3 = 1 + (-3) ≠ (-1) + 3
        try calculator.inputDigit(1)
        calculator.inputOperation(.add)
        calculator.inputOperation(.signChange)
        try calculator.inputDigit(3)
        // 2nd operand should now display as -3
        XCTAssertEqual(calculator.displayValue!, -3.0)
        let result = calculator.evaluate()
        XCTAssertEqual(result, -2.0)
    }
    
    func testSignChangeOnSecondOperandNumbers() {
        // If we've entered the second operand,
        // the sign change should apply to it correctly.
        
        // After entering 'a op b',
        // sign change should apply on b
        // i.e. 'a op b signChange' = 'a op -b'
        
        self.inputAnyNumber()
        self.inputAnyBinaryOperation()
        self.inputAnyNumber()
        
        let b = calculator.displayValue!
        calculator.inputOperation(.signChange)
        XCTAssertEqual(-Double(b), calculator.displayValue!)
    }
    
    func testSignChangeOnSecondOperandDigits() throws {
        // If we've entered the second operand,
        // the sign change should apply to it correctly.
        
        // After entering 'a op b',
        // sign change should apply on b
        // i.e. 'a op b signChange' = 'a op -b'
        
        try self.inputAnyDigits()
        self.inputAnyBinaryOperation()
        try self.inputAnyDigits()
        
        let b = calculator.displayValue!
        calculator.inputOperation(.signChange)
        XCTAssertEqual(-Double(b), calculator.displayValue!)
    }
    
    func testInputAfterEvaluationDigits() throws {
        // Any input after evaluation should be considered fresh input
        // and should override the result of the evaluation
                
        // trigger a simple evaluation
        // 1 + 2 = 3
        try calculator.inputDigit(1)
        calculator.inputOperation(.add)
        try calculator.inputDigit(2)
        guard calculator.evaluate() == 3.0 else {
            assertionFailure("Failed test-case setup.")
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
        
    }
    
    func testAddition() throws {
        // 1 + 5 = 6
        let expectedResult = Double(6)
        
        calculator.inputNumber(1)
        calculator.inputOperation(.add)
        calculator.inputNumber(5)
        
        let actualResult = calculator.evaluate()
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testAdditionDigits() throws {
        // TODO:  test negative operands
        
        // 1 + 5 = 6
        let expectedResult = Double(6)
        
        try! calculator.inputDigit(1)
        calculator.inputOperation(.add)
        try! calculator.inputDigit(5)
        
        let actualResult = calculator.evaluate()
        XCTAssertEqual(actualResult, expectedResult)
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
    
    // TODO: add two pairs of methods for every test - 1. digit input 2. number input
    func testSubtractionDigits() throws {
        // TODO: test negative operands
        
        // 1 - 3 = -2
        // 3 - 1 = 2
        // 1 - 1 = 0
        // 1 - 0 = 1
        let tests: [(a: Int, b: Int, result: Double)] = [
            (1,3,-2),
            (3,1,2),
            (1,1,0),
            (1,0,1)
        ]
        
        for test in tests {
            try? calculator.inputDigit(test.a)
            calculator.inputOperation(.subtract)
            try? calculator.inputDigit(test.b)
            
            let actualResult = calculator.evaluate()
            XCTAssertEqual(actualResult, test.result)
            
            // optionally clear for next test
            if CalculatorCoreTests.which.isMultiple(of: 2) {
                calculator.allClear()
            }
        }
    }
}
