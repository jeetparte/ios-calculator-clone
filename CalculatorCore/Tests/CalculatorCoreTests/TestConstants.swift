//
//  File.swift
//  
//
//  Created by Jeet Parte on 19/03/22.
//

import Foundation
import CalculatorCore

typealias XOperatorY = (a: Int, op: SingleStepCalculator.BinaryOperation, b: Int)
typealias Operator = SingleStepCalculator.BinaryOperation
typealias XOperatorYResult = (a: Int, op: SingleStepCalculator.BinaryOperation, b: Int, expected: Double)
typealias AssertBlock = (_ actualResult: Double, _ expectedResult: Double) -> Void
