//
//  UnaryOperation.swift
//  
//
//  Created by Jeet Parte on 05/04/22.
//

import RealModule

public enum UnaryOperation {
    case signChange // * this one is treated a little differently
    case percentage
            
    // Exponentiation functions
    // a. positive exponents
    case square
    case cube
    case exponential /* e^x */
    case powerOfTen, powerOfTwo
    // b. negative exponents
    case reciprocal
    case squareRoot
    case cubeRoot
    
    // Logarithmic functions
    case naturalLog, commonLog, binaryLog
    
    case factorial
    
    // Trigonometric functions
    case sine, cosine, tangent
    case arcsine, arccosine, arctangent
    case hyperbolicSine, hyperbolicCosine, hyperbolicTangent
    case inverseHyperbolicSine, inverseHyperbolicCosine, inverseHyperbolicTangent
}

internal typealias UnaryFunction = (Double) -> Double?
internal var unaryFunctions: [UnaryOperation: UnaryFunction] = [
    .percentage: {$0 / 100.0},
    .square: {.pow($0, 2)},
    .cube: {.pow($0, 3)},
    .exponential: {.exp($0)},
    .powerOfTen: {.exp10($0)},
    .powerOfTwo: {.exp2($0)},
    .reciprocal: { $0.reciprocal },
    .squareRoot: {.sqrt($0)},
    .cubeRoot: {.root($0, 3)},
    .naturalLog: {.log($0)},
    .commonLog: {.log10($0)},
    .binaryLog: {.log2($0)},
    .factorial: {
        guard let integer = Int(exactly: $0), integer >= 0 else { return nil }
        return factorial(integer)
    },
    .sine: {.sin($0)}, //TODO: this is in radians, add support for degrees
    .cosine: {.cos($0)},
    .tangent: {.tan($0)},
    .arcsine: {.asin($0)},
    .arccosine: {.acos($0)},
    .arctangent: {.atan($0)},
    .hyperbolicSine: {.sinh($0)},
    .hyperbolicCosine: {.cosh($0)},
    .hyperbolicTangent: {.tanh($0)},
    .inverseHyperbolicSine: {.asinh($0)},
    .inverseHyperbolicCosine: {.acosh($0)},
    .inverseHyperbolicTangent: {.atanh($0)},
]

// Just a basic version - no memoization / performance optimization
fileprivate func factorial(_ n: Int) -> Double {
    func fact(_ n: Int, accumulator: Double = 1) -> Double {
        if accumulator == .infinity {
            return .infinity
        }
        if n <= 1 {
            return accumulator
        }
        let acc = Double(n) * accumulator
        let newN = n - 1
        return fact(newN, accumulator: acc)
    }
    
    assert(n >= 0)
    return fact(n)
}
