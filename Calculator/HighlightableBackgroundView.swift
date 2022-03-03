//
//  HighlightableBackgroundView.swift
//  Calculator
//
//  Created by Jeet Parte on 25/02/22.
//

import Foundation
import UIKit

class HighlightableBackgroundView: UIView {
    
    init(normalBackgroundColor: UIColor?, highlightedBackgroundColor: UIColor?) {
        super.init(frame: .zero)
                
        self.configureBackgroundColor(normalBackgroundColor, for: .normal)
        self.configureBackgroundColor(highlightedBackgroundColor, for: .active)
        
        // set the backgroundColor to normal state
        self.backgroundColor = stateBackgroundColorMap[.normal]!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var highlightState: HighlightState = .normal {
        didSet {
            if highlightState == oldValue { return }
            
            switch highlightState {
            case .normal:
                // remove highlight gradually
                if let colorForState = self.stateBackgroundColorMap[highlightState] {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction) {
                        self.backgroundColor = colorForState
                    }
                }
            case .active:
                // apply highlight immediately
                if let colorForState = self.stateBackgroundColorMap[highlightState] {
                    self.backgroundColor = colorForState
                }
            }
        }
    }
    
    private var stateBackgroundColorMap: [HighlightState: UIColor?] = [:]
    
    func configureBackgroundColor(_ color: UIColor?, for state: HighlightableBackgroundView.HighlightState) {
        self.stateBackgroundColorMap[state] = color
    }
    
    enum HighlightState {
        case normal
        case active
    }
}
