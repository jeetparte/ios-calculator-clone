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
    func testStringToDigits() {
        let tests: [(number: String, integerDigits: [Int], fractionalDigits: [Int])] = [
            ("123", [1,2,3], []),
            ("123.0", [1,2,3], [0]),
            ("123.456", [1,2,3], [4,5,6]),
            ("-123.456", [1,2,3], [4,5,6]),
            ("0.0000000013", [0], [0,0,0,0,0,0,0,0,1,3]),
            ("12300000000.0", [1,2,3,0,0,0,0,0,0,0,0], [0]),
            ("0.000000000123", [0], [0,0,0,0,0,0,0,0,0,1,2,3]),
        ]
        
        for test in tests {
            XCTAssertEqual(test.number.integerDigits, test.integerDigits)
            XCTAssertEqual(test.number.fractionalDigits, test.fractionalDigits)
        }
    }
    
    // Not a helper we defined, but something we rely on nonetheless.
    func testStringToDouble() {
        // Having input specified as Strings is easier (so we can extract the digits),
        // but validating output requires Doubles.
        // When expected output equals input, we'd like to rely on this conversion to avoid specifying the number in both formats.
        let tests: [(string: String, expected: Double)] = [
            ("12", 12),
            ("-23", -23),
            ("456", 456),
            ("9999", 9999),
            ("0", 0),
            ("-9999", -9999),
            ("6", 6),
            ("456", 456),
            ("12.0", 12.0),
            ("-23.22", -23.22),
            ("456.777", 456.777),
            ("9999.11", 9999.11),
            ("0.0", 0.0),
            ("0.01", 0.01),
            ("-9999.456", -9999.456),
            ("6.5", 6.5),
            ("456.123", 456.123),
            ("-123456789.012345678", -123456789.012345678),
            ("0.0000000013", 0.0000000013),
            ("100000000000000000000", 1e20)
        ]
        
        for test in tests {
            XCTAssertEqual(Double(test.string), test.expected)
        }
    }
}
