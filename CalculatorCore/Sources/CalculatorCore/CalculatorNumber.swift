//
//  CalculatorNumber.swift
//  
//
//  Created by Jeet Parte on 31/03/22.
//

import Foundation

internal struct CalculatorNumber: Equatable {
    private(set) var value: Double
    var hasInsertedDecimal: Bool = false
    
    init(_ value: Double) {
        self.value = value
    }
    
    init(_ value: Int) {
        self.init(Double(value))
    }
    
    /// The fractional part of the number.
    /// This is typed as `String` to preserve any leading zeroes.
    var fractionalPart: String = "" {
        didSet {
            // Check that this is a valid number.
            guard Int(self.fractionalPart) != nil else { return }
            // Update the wrapped value.
            let integralPart = abs(value.rounded(.towardZero))
            let fractionalPart = Decimal(sign: .plus,
                                         exponent: -fractionalPart.count,
                                         significand: Decimal(string: fractionalPart)!)
            let combinedValue = Double(signOf: value,
                                       magnitudeOf: integralPart + NSDecimalNumber(decimal: fractionalPart).doubleValue)
            self.value = combinedValue
        }
    }
    
    mutating func setValue(_ value: Double) {
        self.value = value
    }
    
    mutating func reset() {
        self = .init(0.0)
    }
}

// MARK: - Wrapper API
extension CalculatorNumber {
    var magnitude: Double.Magnitude {
        return value.magnitude
    }
    
    mutating func negate() {
        value.negate()
    }
}

// MARK: - Operator overloads
extension CalculatorNumber {
    static func + (lhs: Self, rhs: Self) -> Self {
        return .init(lhs.value + rhs.value)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        return .init(lhs.value - rhs.value)
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        return .init(lhs.value * rhs.value)
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        return .init(lhs.value / rhs.value)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs.value = lhs.value + rhs.value
    }
    
    static func -= (lhs: inout Self, rhs: Self) {
        lhs.value = lhs.value - rhs.value
    }
    
    static func *= (lhs: inout Self, rhs: Self) {
        lhs.value = lhs.value * rhs.value
    }
    
    static func /= (lhs: inout Self, rhs: Self) {
        lhs.value = lhs.value / rhs.value
    }
}
