//
//  Constants.swift
//  Calculator
//
//  Created by Jeet Parte on 07/03/22.
//

import Foundation

struct SharedConstants {
    static let orientationChangedNotification = Notification.Name("orientationChanged")
    static let newOrientationUserInfoKey = "newOrientation"
    
    static let buttonWasPressed = Notification.Name("buttonWasPressed")
    static let buttonIdUserInfoKey = "buttonId"
    
    static let selectedBinaryOperationChanged = Notification.Name("selectedBinaryOperationChanged")
    static let selectedBinaryOperationUserInfoKey = "selectedBinaryOperation"
}
