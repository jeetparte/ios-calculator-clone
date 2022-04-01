//
//  Errors.swift
//  
//
//  Created by Jeet Parte on 01/04/22.
//

import Foundation

enum TestError: Error {
    case invalidArgument(errorMessage: String)
    case internalError(nestedErrorDescription: String)
}
