//
//  Utilities.swift
//  Calculator
//
//  Created by Jeet Parte on 10/02/22.
//

import Foundation
import UIKit

extension UITraitCollection {
    var phoneInterfaceOrientation: InterfaceOrientation {
        guard (self.userInterfaceIdiom != .unspecified &&
               self.horizontalSizeClass != .unspecified &&
               self.verticalSizeClass != .unspecified) else {
            return .unknown
        }
        precondition(self.userInterfaceIdiom == .phone, "Unhandled user interface idiom. This only works for iPhone.")
        
        switch (self.horizontalSizeClass, self.verticalSizeClass) {
        case (.compact, .regular):
            return .portrait
        case (.regular, .compact):
            return .landscape // big iPhone
        case (.compact, .compact):
            return .landscape // small iPhone
        default:
            assertionFailure("Could not determine phone interface orientation for size classes: " +
                             "\(self.horizontalSizeClass),  \(self.verticalSizeClass)")
            return .unknown
        }
    }
}

enum InterfaceOrientation {
    case unknown
    case portrait
    case landscape
}

enum CalculationMode {
    case standard
    case scientific
}
