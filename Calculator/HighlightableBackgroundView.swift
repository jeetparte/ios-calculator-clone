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
                
        self.setBackgroundColor(normalBackgroundColor, for: .normal)
        self.setBackgroundColor(highlightedBackgroundColor, for: .higlighted)
        
        // set the backgroundColor to normal state
        defer {
            self.state = .normal
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var state: State = .normal {
        didSet {
            switch state {
            case .normal:
                // remove highlight gradually
                if let colorForState = self.stateBackgroundColorMap[state] {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction) {
                        self.backgroundColor = colorForState
                    }
                }
            case .higlighted:
                // apply highlight immediately
                if let colorForState = self.stateBackgroundColorMap[state] {
                    self.backgroundColor = colorForState
                }
            }
        }
    }
    
    private var stateBackgroundColorMap: [State: UIColor?] = [:]
    
    func setBackgroundColor(_ color: UIColor?, for state: HighlightableBackgroundView.State) {
        self.stateBackgroundColorMap[state] = color
    }
    
    enum State {
        case normal
        case higlighted
    }
}
