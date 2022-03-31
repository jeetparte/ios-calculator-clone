//
//  File.swift
//  
//
//  Created by Jeet Parte on 19/03/22.
//

import Foundation
import CalculatorCore

typealias XOperatorY = (a: Double, op: SingleStepCalculator.BinaryOperation, b: Double)
typealias Operator = SingleStepCalculator.BinaryOperation
typealias XOperatorYResult = (a: Double, op: SingleStepCalculator.BinaryOperation, b: Double, expected: Double)
typealias AssertBlock = (_ actualResult: Double, _ expectedResult: Double) -> Void
