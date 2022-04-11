//
//  ButtonConfiguration.swift
//  Calculator
//
//  Created by Jeet Parte on 13/02/22.
//

import Foundation
import UIKit
import CalculatorCore

struct ButtonConfiguration {
    let id: ButtonID
    let text: String
    let alternateID: ButtonID?
    let alternateText: String?
    var color: ButtonColor
    let textType: ButtonTextType
    
    var hasBinaryOperatorKey: Bool {
        return id.isBinaryOperator || alternateID?.isBinaryOperator == true
    }
    
    init(id: ButtonID, text: String, alternateID: ButtonID? = nil, alternateText: String? = nil, color: ButtonColor, textType: ButtonTextType = .label) {
        self.id = id
        self.text = text
        self.alternateID = alternateID
        self.alternateText = alternateText
        self.color = color
        self.textType = textType
    }
}

enum ButtonTextType {
    case label
    case image
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

enum ButtonID: Hashable {
    var isBinaryOperator: Bool {
        if case .binary(_) = self { return true }
        return false
    }
    
    case digit(Int)
    case decimalPoint
    
    case clear
    case equals
    
    case binary(CalculatorCore.BinaryOperation)
    case unary(CalculatorCore.UnaryOperation)
    case specialInput(CalculatorCore.SpecialInput)
    case memoryFunction(CalculatorCore.MemoryFunction)
    case memoryRecall
        
    case leftParanthesis
    case rightParanthesis
    case changeButtons // the button marked "2nd"
}
