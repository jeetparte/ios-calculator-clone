//
//  File.swift
//  
//
//  Created by Jeet Parte on 19/03/22.
//

import Foundation
import CalculatorCore

typealias XOperatorY = (a: String, op: SingleStepCalculator.BinaryOperation, b: String)
typealias Operator = SingleStepCalculator.BinaryOperation
typealias XOperatorYResult = (a: String, op: SingleStepCalculator.BinaryOperation, b: String, expected: Double)
typealias AssertBlock = (_ actualResult: Double, _ expectedResult: Double) -> Void
