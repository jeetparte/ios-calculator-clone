//
//  File.swift
//  
//
//  Created by Jeet Parte on 19/03/22.
//

import Foundation
import CalculatorCore

typealias XOperatorY = (a: String, op: BinaryOperation, b: String)
typealias Operator = BinaryOperation
typealias XOperatorYResult = (a: String, op: BinaryOperation, b: String, expected: Double)
typealias AssertBlock = (_ actualResult: Double, _ expectedResult: Double) -> Void
