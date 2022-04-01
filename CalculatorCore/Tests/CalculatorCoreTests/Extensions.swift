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

extension Double {
    /// - Returns: An array of the digits (0 to 9) that make up the integer part.
    var integerDigits: [Int] {
        let integerString = try! self.nonScientificString().prefix { $0 != "." }
        return integerString.digits        
    }
    
    /// - Returns: An array of the digits (0 to 9) that make up the fractional part.
    var fractionalDigits: [Int] {
        let string = try! self.nonScientificString()
        guard let decimalIndex = string.firstIndex(of: ".") else { return [] }
        
        let fractionStartIndex = string.index(after: decimalIndex)
        let fractionalString = string.suffix(from: fractionStartIndex)
        
        return fractionalString.digits
    }
    
    // Convert scientific-notation strings into the full written out form
    func nonScientificString() throws -> String {
        let normal = String(self)
        // check if the string is in scientific notation i.e. contains an E
        let isE: (Character) -> Bool = { $0 == "e" || $0 == "E" }
        guard normal.contains(where: isE) else { return normal }
        // check sign of the exponent
        let indexOfE = normal.lastIndex(where: isE)!
        let signIndex = normal.index(after: indexOfE)
        let sign = normal[signIndex]
        guard let exponent = Int(normal.suffix(from: signIndex).dropFirst()) else {
            assertionFailure("Unable to infer exponent for string \(normal).")
            return normal
        }
        assert(exponent >= 0)
        var significand = String(normal.prefix(upTo: indexOfE))
        if !significand.contains(".") {
            significand.append(contentsOf: ".0")
        }
        do {
            if sign == "+" {
                // shift decimal to the right, 'exponent' times
                for _ in 0..<exponent {
                    let decimalIndex = significand.firstIndex(of: ".")!
                    try significand.shiftToRight(index: decimalIndex)
                }
                return significand
            } else if sign == "-" {
                // shift decimal to the left, 'exponent' times
                for _ in 0..<exponent {
                    let decimalIndex = significand.firstIndex(of: ".")!
                    try significand.shiftToLeft(index: decimalIndex)
                }
                return significand
            } else {
                assertionFailure("Found unexpected character \(sign) after 'e' in scientific notation.")
                return normal
            }
        } catch {
            throw TestError.internalError(nestedErrorDescription: error.localizedDescription)
        }
    }
}

extension String {
    mutating func shiftToLeft(index i: String.Index) throws {
        guard i > self.startIndex else {
            throw TestError.invalidArgument(
                errorMessage: "Argument index \(i) is the start index. Cannot shift further left.")
        }
        let previousIndex = self.index(before: i)
        var substitute = ""
        if previousIndex == self.startIndex {
            substitute.append("0")
        }
        let current = self[i]
        let previous = self[previousIndex]
        substitute.append(current)
        substitute.append(previous)

        self.replaceSubrange(previousIndex...i, with: substitute)
    }
    
    mutating func shiftToRight(index i: String.Index) throws {
        let nextIndex = self.index(after: i)
        if nextIndex >= self.endIndex {
            throw TestError.invalidArgument(
                errorMessage: "Argument index \(i) is the end index. Cannot shift further right.")
        }
        let lastValidIndex = self.index(before: self.endIndex)
        var substitute = ""
        let current = self[i]
        let next = self[nextIndex]
        substitute.append(next)
        substitute.append(current)        
        if nextIndex == lastValidIndex {
            substitute.append("0")
        }
        
        self.replaceSubrange(i...nextIndex, with: substitute)
    }
}
