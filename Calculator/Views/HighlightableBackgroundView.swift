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
        self.configureBackgroundColor(.white, for: .selected) // TODO: - different for scientific buttons
        
        // set the backgroundColor to normal state
        self.backgroundColor = stateBackgroundColorMap[.normal]!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var highlightState: HighlightState = .normal {
        didSet {
            if highlightState == oldValue { return }
            
            print(oldValue, " --> ", highlightState)
            switch highlightState {
                // TODO: - we might want to consider the old state as well to determine the correct transition
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
            case .selected:
                if let colorForState = self.stateBackgroundColorMap[highlightState] {
                    UIView.animate(withDuration: 0.2) {
                        self.backgroundColor = colorForState
                    }
                }
            }
            
            self.previousHighlightState = oldValue
        }
    }
    
    var previousHighlightState: HighlightState?
    
    var stateBackgroundColorMap: [HighlightState: UIColor?] = [:]
    
    func configureBackgroundColor(_ color: UIColor?, for state: HighlightableBackgroundView.HighlightState) {
        self.stateBackgroundColorMap[state] = color
    }
    
    /// Prefer to use this over setting the *highlightState* property directly.
    func activateHighlight() {
        self.highlightState = .active
    }
    
    /// Reverts the view to the previous non-highlighted state.
    func removeHighlight() {
        guard self.highlightState == .active else { return }
        
        if let previous = self.previousHighlightState {
            assert(previous != .active)
            self.highlightState = previous
        }
    }
    
    enum HighlightState {
        case normal
        case active // TODO: - rename
        case selected
    }
}
