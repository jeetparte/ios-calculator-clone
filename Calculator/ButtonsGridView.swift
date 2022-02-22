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
    /// We setup height and width constraints for the first button and then constrain the other buttons in relation to this one.
    var firstStandardButton: UIView!
    
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
            self.setButtonSpacing(for: newOrientation)
        case .landscape:
            self.calculationMode = .scientific
            self.activateConstraints(for: newOrientation)
            self.setButtonSpacing(for: newOrientation)
        default: break
        }
    }
    
    private func setupSubviews() {
        let rowIndices = 0..<5
        rowIndices.forEach {
            self.configureRow(index: $0)
        }
    }
    
    private func configureRow(index rowIndex: Int) {
        let row = UIStackView()
        row.axis = .horizontal
        
//        row.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
        self.addArrangedSubview(row)
        
        // Create views
        let scientificRowButtons: [ButtonView] = Calculator.scientificButtons[rowIndex].map {            
            let button = ButtonView(buttonConfiguration: $0)
            row.addArrangedSubview(button)
            return button
        }
        let standardRowButtons: [ButtonView] = Calculator.standardButtons[rowIndex].map {
            let button = ButtonView(buttonConfiguration: $0)
            row.addArrangedSubview(button)
            return button
        }
        
        self.allScientificButtons[rowIndex] = scientificRowButtons
        
        scientificRowButtons.forEach { button in
//            row.addArrangedSubview(button)
            
            // we don't show scientific buttons in portrait mode, but this constraint
            // make the visual transition during orientation change smooth
            let pc = button.heightAnchor.constraint(equalTo: button.widthAnchor)
            pc.identifier = button.buttonConfiguration.text
            self.portraitConstraints.append(pc)
            
            let lc = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: Constants.buttonAspectRatio)
            lc.identifier = button.buttonConfiguration.text
            self.landscapeConstraints.append(lc)
        }
        
        self.configureStandardButtons(standardRowButtons, rowIndex: rowIndex)
    }
    
    /// We configure standard buttons' constraints a little differently, because it has a double width button
    private func configureStandardButtons(_ standardRowButtons: [ButtonView], rowIndex: Int) {
        if rowIndex == 0 {
            assert(!standardRowButtons.isEmpty)
            
            guard let firstStandardButton = standardRowButtons.first else { return }
            self.firstStandardButton = firstStandardButton
            do {
                let pc = firstStandardButton.widthAnchor.constraint(equalTo: firstStandardButton.heightAnchor)
                pc.identifier = firstStandardButton.buttonConfiguration.text
                self.portraitConstraints.append(pc)
                
                let lc = firstStandardButton.heightAnchor.constraint(equalTo: firstStandardButton.widthAnchor, multiplier: Constants.buttonAspectRatio)
                lc.identifier = firstStandardButton.buttonConfiguration.text
                self.landscapeConstraints.append(lc)
            }
        }
        
        // skip the first button on row 0,
        // skip the first button on row 4 (it should take double width - what is what
        // we want - automatically when we don't give it constraints)
        let dropCount = (rowIndex == 0 || rowIndex == 4) ? 1 : 0
        standardRowButtons.dropFirst(dropCount).forEach { button in
            let widthConstraint = button.widthAnchor.constraint(equalTo: firstStandardButton.widthAnchor)
            let heightConstraint = button.heightAnchor.constraint(equalTo: firstStandardButton.heightAnchor)
            widthConstraint.identifier = button.buttonConfiguration.text
            heightConstraint.identifier = button.buttonConfiguration.text
            
            widthConstraint.isActive = true
            heightConstraint.isActive = true
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
    
    private func setButtonSpacing(for orientation: InterfaceOrientation) {
        var horizontalSpacing: CGFloat
        var verticalSpacing: CGFloat
        switch orientation {
        case .landscape:
            horizontalSpacing = Constants.Landscape.interButtonSpacingHorizontal
            verticalSpacing = Constants.Landscape.interButtonSpacingVertical
        default:
            // portrait and otherwise
            horizontalSpacing = Constants.Portrait.interButtonSpacingHorizontal
            verticalSpacing = Constants.Portrait.interButtonSpacingVertical
            break
        }
        
        self.spacing = verticalSpacing
        self.arrangedSubviews.forEach {
            if let row = $0 as? UIStackView, row.axis == .horizontal {
                row.spacing = horizontalSpacing
            }
        }
    }
    
    private struct Constants {
        struct Portrait {
            static let interButtonSpacingVertical: CGFloat = 14
            static let interButtonSpacingHorizontal: CGFloat = 14
        }
        struct Landscape {
            static let interButtonSpacingVertical: CGFloat = 9
            static let interButtonSpacingHorizontal: CGFloat = 9
        }
        
        static let buttonAspectRatio: CGFloat = 0.83 // height:width
    }
}
