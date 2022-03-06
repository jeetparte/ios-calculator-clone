//
//  ButtonConfiguration.swift
//  Calculator
//
//  Created by Jeet Parte on 13/02/22.
//

import Foundation
import UIKit

struct ButtonConfiguration {
    let id: ButtonID
    let text: String
    let alternateID: ButtonID?
    let alternateText: String?
    var color: ButtonColor
    
    init(id: ButtonID, text: String, alternateID: ButtonID? = nil, alternateText: String? = nil, color: ButtonColor) {
        self.id = id
        self.text = text
        self.alternateID = alternateID
        self.alternateText = alternateText
        self.color = color
    }
}

enum ButtonColor {
    case accentColor
    case standardButtonColor
    case standardButtonProminent
    case scientificButtonColor
    case scientificButtonSelected // * This is a transient state unlike the rest.
    
    // MARK: - Utilities
    private static let standardColors: [ButtonColor] = [.accentColor, .standardButtonColor, .standardButtonProminent]
    var isStandard: Bool {
        return Self.standardColors.contains(self)
    }
    private static let scientificColors: [ButtonColor] = [.scientificButtonColor, .scientificButtonSelected]
    var isScientific: Bool {
        return Self.scientificColors.contains(self)
    }
}

enum ButtonID {
    // MARK: - Primary buttons (standard calculator)
    case clear
    case signChange
    case percentage
    case division
    case multiplication
    case subtraction
    case addition
    case equals
    
    case decimalPoint
    
    case zero
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    
    // MARK: - Secondary buttons (scientific calculator)
    case leftParanthesis
    case rightParanthesis
    // Memory functions
    case mClear
    case mAdd
    case mSubtract
    case mRecall
    
    case changeButtons // the button marked "2nd"
    
    // Exponentiation functions
    // a. positive exponents
    case square
    case cube
    case power
    case exponential /* e^x */, powerReverseOperands
    case powerOfTen, powerOfTwo
    // b. negative exponents
    case reciprocal // 1/x
    case squareRoot
    case cubeRoot
    case nthRoot
    
    // Logarithmic functions
    case naturalLog, logToTheBase
    case commonLog, binaryLog
    
    case factorial
    
    // Trigonometric functions
    case sine, cosine, tangent
    case arcsine, arccosine, arctangent
    case hyperbolicSine, hyperbolicCosine, hyperbolicTangent
    case inverseHyperbolicSine, inverseHyperbolicCosine, inverseHyperbolicTangent
    
    case eulersConstant
    case enterExponent // scientific notation
    case toggleDegreesOrRadians
    case pi
    case randomNumber
}
