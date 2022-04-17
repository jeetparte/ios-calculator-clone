//
//  Extensions.swift
//  
//
//  Created by Jeet Parte on 19/03/22.
//

import Foundation

extension Int {
    var isEven: Bool {
        return self.isMultiple(of: 2)
    }
}

extension String {
    /// - Returns: An array of the digits (0 to 9) that make up the integer part.
    var integerDigits: [Int] {
        let integerString = self.prefix { $0 != "." }
        return integerString.digits
    }
    
    /// - Returns: An array of the digits (0 to 9) that make up the fractional part.
    var fractionalDigits: [Int] {
        let string = self
        guard let decimalIndex = string.firstIndex(of: ".") else { return [] }
        
        let fractionStartIndex = string.index(after: decimalIndex)
        let fractionalString = string.suffix(from: fractionStartIndex)
        
        return fractionalString.digits
    }
}

fileprivate extension StringProtocol {
    var digits: [Int] {
        return self.compactMap {
            let d = $0.wholeNumberValue
            if d != nil {
                assert((0...9) ~= d!)
            }
            return d
        }
    }
}
