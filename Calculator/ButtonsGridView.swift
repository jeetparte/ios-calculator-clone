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
                self.toggleVisibilityForScientificButtons(makeVisible: false)
            case .scientific:
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
        let rowIndices = 0..<4
        rowIndices.forEach {
            self.configureRow(index: $0)
        }
    }
    
    private func configureRow(index: Int) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8.0
        
//        row.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
        self.addArrangedSubview(row)
        
        // Create views
        let standardButtons: [ButtonView] = Calculator.standardButtons[index].map {
            ButtonView(buttonConfiguration: $0)
        }
        let scientificButtons: [ButtonView] = Calculator.scientificButtons[index].map {
            ButtonView(buttonConfiguration: $0)
        }
        
        self.allScientificButtons[index] = scientificButtons
        
        scientificButtons.forEach { button in
            row.addArrangedSubview(button)
            
            // we don't show scientific buttons in portrait mode, but this constraint
            // make the visual transition during orientation change smooth
            let pc = button.heightAnchor.constraint(equalTo: button.widthAnchor)
            pc.identifier = button.buttonConfiguration.text
            self.portraitConstraints.append(pc)
            
            let lc = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.7)
            lc.identifier = button.buttonConfiguration.text
            self.landscapeConstraints.append(lc)
        }
        
        standardButtons.forEach { button in            
            row.addArrangedSubview(button)
            
            let pc = button.heightAnchor.constraint(equalTo: button.widthAnchor)
            pc.identifier = button.buttonConfiguration.text
            self.portraitConstraints.append(pc)
            
            let lc = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.7)
            lc.identifier = button.buttonConfiguration.text
            self.landscapeConstraints.append(lc)
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
                button.alpha = makeVisible ? 1.0 : 0.0
            }
        }
    }
    
    private struct Constants {
        static let interButtonSpacingPortrait: CGFloat = 10.00
        static let interButtonSpacingLandscape: CGFloat = 10.00
        static let buttonAspectRatio: CGFloat = 0.83 // height:width
    }
}
