//
//  RandomTests.swift
//  CalculatorCoreTests
//
//  Created by Jeet Parte on 19/03/22.
//

import XCTest
@testable import CalculatorCore

/**
 These tests provide generator functions that apply random values (in a valid range) for any inputs that are irrelevant to the test result.
 See https://softwareengineering.stackexchange.com/a/429622/342114.
 
 Ideally, we'd want to record the seed value as part of the test results so that we can reproduce tests that fail.
 */
class RandomTests: XCTestCase {
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
    // MARK: - Random input-generator functions
    @discardableResult private func inputAnyNumber(in range: ClosedRange<Int>? = nil) -> Int {
        let range = range ?? -999_999_999...999_999_999
        let number = Int.random(in: range)
        calculator.inputNumber(number)
        
        return number
    }
    
    @discardableResult private func inputAnyDigits(numberOfDigits n: Int? = nil) throws -> Int {
        let n = n ?? Int.random(in: 1...10)
        let count = (1...n)
        
        var number = 0
        for _ in count {
            let d = Int.random(in: 0...9)
            try calculator.inputDigit(d)
            
            number *= 10
            number += d
        }
        return number
    }
    
    @discardableResult private func anyInput() throws -> Int {
        switch Self.which {
        case 1:
            // Use number input
            return self.inputAnyNumber()
        case 2:
            // Use digit input
            return try self.inputAnyDigits()
        default:
            // Use random input
            let even = Int.random(in: 1...2).isMultiple(of: 2)
            if even {
                return try self.inputAnyDigits()
            } else {
                return self.inputAnyNumber()
            }
        }
    }
    
    private func inputAnyBinaryOperation() {
        calculator.inputOperation(.allCases.randomElement()!)
    }

    // MARK: - Tests
    
    func testPartialEvaluation() throws {
        // The sequence of operations
        // a, op, =,
        // should evaluate to a.
        
        // and
        // the sequence of operations
        // a, op, =,b, =
        // should evaluate to b.
        
        let a = try! self.anyInput()
        self.inputAnyBinaryOperation()
        let result1 = calculator.evaluate()
        XCTAssertEqual(result1, Double(a))
        
        let b = try! self.anyInput()
        let result2 = calculator.evaluate()
        XCTAssertEqual(result2, Double(b))
    }
    
    func testSignChangeOnSecondOperand() throws {
        // If we've entered the second operand,
        // the sign change should apply to it correctly.
        
        // After entering 'a op b',
        // sign change should apply on b
        // i.e. 'a op b signChange' = 'a op -b'
        
        try self.anyInput()
        self.inputAnyBinaryOperation()
        let b = try self.anyInput()
        XCTAssertEqual(Double(b), calculator.displayValue!)
        
        calculator.inputOperation(.signChange)
        XCTAssertEqual(-Double(b), calculator.displayValue!)
    }
}
