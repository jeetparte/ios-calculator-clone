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
    
    private func newCalculator() {
        if CalculatorCoreTests.which.isMultiple(of: 2) {
            calculator?.allClear()
        } else {
            calculator = .init()
        }
    }
    
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
        
        // 1 + signChange(3) = -2 ≠ 2
        try calculator.inputDigit(1)
        calculator.inputOperation(.add)
        calculator.inputOperation(.signChange)
        try calculator.inputDigit(3)
        // 2nd operand should now display as -3
        XCTAssertEqual(calculator.displayValue!, -3.0)
        let result = calculator.evaluate()
        XCTAssertEqual(result, -2.0)
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
        // TODO: - test negative operands
        
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
        // TODO: - test negative operands
        
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
