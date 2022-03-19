//
//  File.swift
//  
//
//  Created by Jeet Parte on 19/03/22.
//

import Foundation

extension Int {
    /// - Returns: An array of the digits (0 to 9) that make up the integer. Sign is ignored.
    var digits: [Int] {
        return String(self).compactMap{
            let d = $0.wholeNumberValue
            if d != nil {
                assert((0...9) ~= d!)
            }
            return d
        }
    }
}
