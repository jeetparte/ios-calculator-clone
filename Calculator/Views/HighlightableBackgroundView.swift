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
        self.configureBackgroundColor(highlightedBackgroundColor, for: .highlighted)
        self.configureBackgroundColor(.white, for: .selected) // TODO: - different for scientific buttons
        
        // set the backgroundColor to normal state
        self.backgroundColor = stateBackgroundColorMap[.normal]!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var visualState: VisualState = .normal {
        didSet {
            if visualState == oldValue { return }
            
//            print(oldValue, " --> ", visualState)
            switch visualState {
                // TODO: - we might want to consider the old state as well to determine the correct transition
            case .normal:
                // remove highlight gradually
                if let colorForState = self.stateBackgroundColorMap[visualState] {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction) {
                        self.backgroundColor = colorForState
                    }
                }
            case .highlighted:
                // apply highlight immediately
                if let colorForState = self.stateBackgroundColorMap[visualState] {
                    self.backgroundColor = colorForState
                }
            case .selected:
                if let colorForState = self.stateBackgroundColorMap[visualState] {
                    UIView.animate(withDuration: 0.2) {
                        self.backgroundColor = colorForState
                    }
                }
            }
            
            self.previousVisualState = oldValue
        }
    }
    
    var previousVisualState: VisualState?
    
    var stateBackgroundColorMap: [VisualState: UIColor?] = [:]
    
    func configureBackgroundColor(_ color: UIColor?, for state: HighlightableBackgroundView.VisualState) {
        self.stateBackgroundColorMap[state] = color
    }
    
    /// Prefer to use this over setting the *visualState* property directly.
    func activateHighlight() {
        self.visualState = .highlighted
    }
    
    /// Reverts the view to the previous non-highlighted state.
    func removeHighlight() {
        guard self.visualState == .highlighted else { return }
        
        if let previous = self.previousVisualState {
            assert(previous != .highlighted)
            self.visualState = previous
        }
    }
    
    enum VisualState {
        case normal
        case highlighted // TODO: - rename
        case selected
    }
}
