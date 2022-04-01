//
//  HelperTests.swift
//  CalculatorCoreTests
//
//  Created by Jeet Parte on 30/03/22.
//

import XCTest

// Quis custodiet ipsos custodes? Who will test the tests themselves?
// We added some helpers for our tests. Now we need to test the helpers as well.
class HelperTests: XCTestCase {
    func testDoubleToDigits() {
        let tests: [(number: Double, integerDigits: [Int], fractionalDigits: [Int])] = [
            (123, [1,2,3], [0]),
            (123.0, [1,2,3], [0]),
            (123.456, [1,2,3], [4,5,6]),
            (-123.456, [1,2,3], [4,5,6]),
            (0.0000000013, [0], [0,0,0,0,0,0,0,0,1,3]),
            (1.23e10, [1,2,3,0,0,0,0,0,0,0,0], [0]),
            (1.23e-10, [0], [0,0,0,0,0,0,0,0,0,1,2,3]),
        ]
        
        for test in tests {
            XCTAssertEqual(test.number.integerDigits, test.integerDigits)
            XCTAssertEqual(test.number.fractionalDigits, test.fractionalDigits)
        }
    }
    
    func testStringShiftToLeft() {
        let testCharacter: Character = "."
        let tests: [(input: String, expected: String)] = [
            ("12.3", expected: "1.23"),
            ("1.23", expected: "0.123"),
        ]
        
        for test in tests {
            let index = test.input.firstIndex(of: testCharacter)!
            var result = test.input
            XCTAssertNoThrow(try result.shiftToLeft(index: index))
            XCTAssertEqual(result, test.expected)
        }
    }
    
    func testStringShiftToLeftError() {
        let testCharacter: Character = "."
        var test = ".123"
        let index = test.firstIndex(of: testCharacter)!
        XCTAssertThrowsError(try test.shiftToLeft(index: index))
    }
    
    func testStringShiftToRight() {
        let testCharacter: Character = "."
        let tests: [(input: String, expected: String)] = [
            ("12.3", expected: "123.0"),
            ("1.23", expected: "12.3"),
        ]
        
        for test in tests {
            let index = test.input.firstIndex(of: testCharacter)!
            var result = test.input
            XCTAssertNoThrow(try result.shiftToRight(index: index))
            XCTAssertEqual(result, test.expected)
        }
    }
    
    func testStringShiftToRightError() {
        let testCharacter: Character = "."
        var test = "123."
        let index = test.firstIndex(of: testCharacter)!
        XCTAssertThrowsError(try test.shiftToRight(index: index))
    }
    
}
