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
        
        self.spacing = Constants.interButtonSpacingVertical
        
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
        row.spacing = Constants.interButtonSpacingHorizontal
        
//        row.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
        self.addArrangedSubview(row)
        
        // Create views
        let standardButtons: [ButtonView] = Calculator.standardButtons[rowIndex].map {
            ButtonView(buttonConfiguration: $0)
        }
        let scientificButtons: [ButtonView] = Calculator.scientificButtons[rowIndex].map {
            ButtonView(buttonConfiguration: $0)
        }
        
        self.allScientificButtons[rowIndex] = scientificButtons
        
        scientificButtons.forEach { button in
            row.addArrangedSubview(button)
            
            // we don't show scientific buttons in portrait mode, but this constraint
            // make the visual transition during orientation change smooth
            let pc = button.heightAnchor.constraint(equalTo: button.widthAnchor)
            pc.identifier = button.buttonConfiguration.text
            self.portraitConstraints.append(pc)
            
            let lc = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: Constants.buttonAspectRatio)
            lc.identifier = button.buttonConfiguration.text
            self.landscapeConstraints.append(lc)
        }
        
        standardButtons.forEach { button in            
            row.addArrangedSubview(button)
            
            // double width for .zero button in row 5
            let isZeroButton = rowIndex == 4 && button.buttonConfiguration.id == .zero
            let multiplier = isZeroButton ? 2.0 : 1.0
            let constant = isZeroButton ? Constants.interButtonSpacingHorizontal : 0
            let pc = button.widthAnchor.constraint(equalTo: button.heightAnchor,
                                                   multiplier: multiplier,
                                                   constant: constant)
            pc.identifier = button.buttonConfiguration.text
            self.portraitConstraints.append(pc)
            
            if !isZeroButton {
                let lc = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: Constants.buttonAspectRatio)
                lc.identifier = button.buttonConfiguration.text
                self.landscapeConstraints.append(lc)
            } else {
                // set width / height based on adjacent buttons
                assert(row.arrangedSubviews.count >= 2)
                let prev = row.arrangedSubviews.first!
                let lc1 = button.heightAnchor.constraint(equalTo: prev.heightAnchor)
                lc1.identifier = button.buttonConfiguration.text
                let lc2 = button.widthAnchor.constraint(equalTo: prev.widthAnchor, multiplier: 2, constant: Constants.interButtonSpacingHorizontal)
                lc2.identifier = button.buttonConfiguration.text
                self.landscapeConstraints.append(contentsOf: [lc1, lc2])
            }
            
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
            horizontalSpacing = Constants.interButtonSpacingHorizontal - 2
            verticalSpacing = Constants.interButtonSpacingVertical - 2
        default:
            // portrait and otherwise
            horizontalSpacing = Constants.interButtonSpacingHorizontal
            verticalSpacing = Constants.interButtonSpacingVertical
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
        static let interButtonSpacingVertical: CGFloat = 10.00
        static let interButtonSpacingHorizontal: CGFloat = 10.00
        static let buttonAspectRatio: CGFloat = 0.83 // height:width
    }
}
