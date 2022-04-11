//
//  BinaryOperation.swift
//  
//
//  Created by Jeet Parte on 08/04/22.
//
import RealModule

public enum BinaryOperation: CaseIterable {
    case multiply
    case divide
    case add
    case subtract
    case power
    case powerReverseOperands // * should we implement this?
    case nthRoot
    case logToTheBase
    case enterExponent // scientific notation
}

typealias BinaryFunction = (Double, Double) -> Double?

let binaryFunctions: [BinaryOperation: BinaryFunction] = [
    .multiply: { $0 * $1 },
    .divide: { $0 / $1 },
    .add: { $0 + $1 },
    .subtract: { $0 - $1 },
    .power: { Double.pow($0, $1) },
    .powerReverseOperands: { Double.pow($1, $0) },
    .nthRoot: {
        guard let n = Int(exactly: $1) else { return nil }
        return Double.root($0, n)
    },
    .logToTheBase: { Double.log10($0) / Double.log10($1) },
    .enterExponent: { $0 * Double.pow(10, $1) },
]
