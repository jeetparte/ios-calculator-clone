//
//  ButtonsView.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ButtonsGridView: UIStackView {
    
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    
    var allScientificButtons: [[UIView]] = .init(repeating: [], count: 5) // five rows
    
    var calculationMode: CalculationMode = .standard {
        didSet {
            switch calculationMode {
            case .standard:
//                print("switched to standard calculation mode")
                self.toggleVisibilityForScientificButtons(makeVisible: false)
            case .scientific:
//                print("switched to scientific calculation mode")
                self.toggleVisibilityForScientificButtons(makeVisible: true)
            }
            
        }
    }
            
    init() {
        super.init(frame: .zero)
        
        // Configure stack view
        self.axis = .vertical
        self.distribution = .fill
        self.alignment = .fill
        
        self.spacing = 8.0
        
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
        
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.heightAnchor.constraint(equalToConstant: 250).isActive = true
                
        self.setupSubviews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleOrientationChange(newOrientation: InterfaceOrientation) {
        switch newOrientation {
        case .portrait:
            self.calculationMode = .standard
            self.activateConstraints(for: newOrientation)
        case .landscape:
            self.calculationMode = .scientific
            self.activateConstraints(for: newOrientation)
        default: break
        }
    }
    
    private func setupSubviews() {
        self.configureRow1()
        
        
        // activate constraints
        let currentOrientation = self.traitCollection.phoneInterfaceOrientation
        self.handleOrientationChange(newOrientation: currentOrientation)
    }
    
    private func configureRow1() {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8.0
        
//        row.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
        self.addArrangedSubview(row)
        
        // Create views for row 1 buttons
        let standardButtons: [ButtonView] = Calculator.standardButtons[0].map { buttonConfig in
            let button = ButtonView(buttonConfiguration: buttonConfig)
            return button
        }
        let scientificButtons: [ButtonView] = Calculator.scientificButtons[0].map { buttonConfig in
            let button = ButtonView(buttonConfiguration: buttonConfig)
            return button
        }
        
        self.allScientificButtons[0] = scientificButtons
        
        scientificButtons.forEach { button in
            row.addArrangedSubview(button)
            
            // we don't show scientific buttons in portrait mode, but these constraints
            // make the visual transition during orientation change smooth
            self.portraitConstraints.append(contentsOf: [
                button.heightAnchor.constraint(equalTo: button.widthAnchor)
            ])
            
            self.landscapeConstraints.append(contentsOf: [
                button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.7)
            ])
        }
        
        standardButtons.forEach { button in            
            row.addArrangedSubview(button)
            
            self.portraitConstraints.append(contentsOf: [
                button.heightAnchor.constraint(equalTo: button.widthAnchor)
            ])
            
            self.landscapeConstraints.append(contentsOf: [
                button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.7)
            ])
        }
    }
    
    private func activateConstraints(for orientation: InterfaceOrientation) {
        // first deactivate current constraints!
        switch orientation {
        case .portrait:
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        case .landscape:
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        default:
            break
        }
    }
    
    private func toggleVisibilityForScientificButtons(makeVisible: Bool) {
        self.allScientificButtons.forEach { buttonsRow in
            buttonsRow.forEach { button in
                button.isHidden = !makeVisible
                
                // make visual transition smooth
                button.alpha = 1.0 - button.alpha // toggles between 0 and 1
            }
        }
    }
    
    private struct Constants {
        static let interButtonSpacingPortrait: CGFloat = 10.00
        static let interButtonSpacingLandscape: CGFloat = 10.00
        static let buttonAspectRatio: CGFloat = 0.83 // height:width
    }
}
