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
        // TODO: add the missing tests
        let tests: [(number: Double, integerDigits: [Int], fractionalDigits: [Int])] = [
            (123, [1,2,3], [0]),
            (123.0, [1,2,3], [0]),
            (123.456, [1,2,3], [4,5,6]),
            (-123.456, [1,2,3], [4,5,6]),
        ]
        
        for test in tests {
            XCTAssertEqual(test.number.integerDigits, test.integerDigits)
            XCTAssertEqual(test.number.fractionalDigits, test.fractionalDigits)
        }
    }
}
