//
//  Utilities.swift
//  Calculator
//
//  Created by Jeet Parte on 10/02/22.
//

import Foundation
import UIKit

enum InterfaceOrientation {
    case unknown
    case portrait
    case landscape
}

extension UIInterfaceOrientation {
    var simpleOrientation: Calculator.InterfaceOrientation {
        if self.isPortrait {
            return .portrait
        } else if self.isLandscape {
            return .landscape
        } else {
            return .unknown
        }
    }
}

enum CalculationMode {
    case standard
    case scientific
}
