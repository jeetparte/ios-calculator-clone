//
//  ButtonView.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ButtonView: HighlightableBackgroundView {
    var buttonConfiguration: ButtonConfiguration
    var id: ButtonID
        
    private var previousFontSize: CGFloat?
    private var foreground: ButtonForegroundProvider
    
    override var visualState: HighlightableBackgroundView.VisualState {
        didSet {
            guard visualState != oldValue else { return }
            
            // change foreground color when selected or unselected
            switch (oldValue, visualState) {
            case (_, .selected):
                let selectedTextColor: UIColor?
                if self.buttonConfiguration.color == .accentColor {
                    // Change foreground color to normal variant of background color
                    selectedTextColor = self.stateBackgroundColorMap[.normal]!
                } else if self.buttonConfiguration.color == .scientificButtonColor {
                    selectedTextColor = .black
                } else {
                    assertionFailure("Unhandled case")
                    return
                }
                foreground.setTextColor(selectedTextColor)
            case (_, .normal):
                // Revert foreground color to previous state
                foreground.setTextColor(nil)
            default:
                break
            }
        }
    }
    
    init(buttonConfiguration: ButtonConfiguration) {
        self.buttonConfiguration = buttonConfiguration
        self.id = buttonConfiguration.id
        self.foreground = ButtonForegroundProvider(buttonConfiguration: buttonConfiguration)
        
        // set the background for various states
        let backgroundColors = Self.getBackgroundColors(for: buttonConfiguration)
        super.init(normalBackgroundColor: backgroundColors.normal,
                   highlightedBackgroundColor: backgroundColors.highlighted, selectedBackgroundColor: backgroundColors.selected)
                
//        self.layer.borderColor = UIColor.systemRed.cgColor
//        self.layer.borderWidth = 1.0
        
        self.initializeForegroundText()
        // update foreground whenever an orientation change notification is posted
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateForegroundText(_:)), name: SharedConstants.orientationChangedNotification, object: nil)
        
        if self.id.isBinaryOperator {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeBinaryOperation(_:)), name: SharedConstants.selectedBinaryOperationChanged, object: nil)
        }
        
        if self.id == .mRecall {
            self.selectionAnimationDuration = 0.5
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.memoryRecallSelectionStateChanged(_:)), name: SharedConstants.shouldChangeMemoryRecallButtonSelectionState, object: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.height/2
//        self.layer.cornerCurve = .continuous
    }
    
    func buttonTap() {
//        print("tapped \(self.buttonConfiguration.text)")        
        NotificationCenter.default.post(name: SharedConstants.buttonWasPressed, object: self, userInfo: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeForegroundText() {
        let foregroundView = foreground.getView()
        self.addSubview(foregroundView)
        foregroundView.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        foregroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc func updateForegroundText(_ orientationChangeNotification: Notification) {
        guard let userInfo = orientationChangeNotification.userInfo,
              let newOrientation = userInfo[SharedConstants.newOrientationUserInfoKey] as?
                InterfaceOrientation else {
                    assertionFailure(
                        "An orientation-change notification was posted without information about the new orientation. " +
                        "Cannot decide buttons' foreground appearance for unknown orientation.")
                    return
                }
        
        let fontSize = Self.getFontSize(for: buttonConfiguration.color, orientation: newOrientation)
        if self.previousFontSize == nil {
            // setting font for the first time
            let weight = Self.getFontWeight(for: buttonConfiguration.color)
            foreground.setFont(size: fontSize, weight: weight)
            self.previousFontSize = fontSize

            return
        }
        
        guard fontSize != self.previousFontSize else { return }
        // visually, the font size changes abruptly, so we use this transition animation to smooth it out
        UIView.transition(with: foreground.getView(), duration: 0.0, options: [.transitionCrossDissolve]) { [self] in
            foreground.updateFont(size: fontSize)
        }
        self.previousFontSize = fontSize
    }
    
    // MARK: - Special button handlers
    @objc func didChangeBinaryOperation(_ binaryOperationChangedNotification: Notification) {
        guard let userInfo = binaryOperationChangedNotification.userInfo,
              let infoUnderKey = userInfo[SharedConstants.selectedBinaryOperationUserInfoKey],
              let operationToSelect =  infoUnderKey as? ButtonID? else {
            assertionFailure("Could not obtain necessary information from notification")
            return
        }
        
        if self.id == operationToSelect {
            self.visualState = .selected
        } else {
            self.visualState = .normal
        }
    }
    
    @objc func memoryRecallSelectionStateChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let shouldSelect =
                userInfo[SharedConstants.shouldSelectMemoryRecallButton] as? Bool else {
            assertionFailure("Could not obtain necessary information from Notification.")
            return
        }
        
        if shouldSelect {
            self.visualState = .selected
        } else {
            self.visualState = .normal
        }
    }
    
    // MARK: -
    private static func getFontWeight(for buttonColor: ButtonColor) -> UIFont.Weight {
        switch buttonColor {
        case _ where buttonColor.isScientific:
            return .medium
        case .standardButtonProminent, .accentColor:
            return .medium
        default:
            return .regular
        }
    }
    
    private static func getFontSize(for buttonColor: ButtonColor, orientation: InterfaceOrientation) -> CGFloat {
        switch buttonColor {
        // Special cases
        case .standardButtonProminent:
            if orientation == .portrait {
                return Constants.Portrait.standardButtonProminentFontSize
            }
            if orientation == .landscape {
                return Constants.Landscape.standardButtonProminentFontSize
            }
        case .accentColor:
            if orientation == .portrait {
                return Constants.Portrait.accentButtonFontSize
            }
            if orientation == .landscape {
                return Constants.Landscape.accentButtonFontSize
            }
        // General cases
        case _ where buttonColor.isStandard:
            if orientation == .portrait {
                return Constants.Portrait.standardButtonFontSize
            }
            if orientation == .landscape {
                return Constants.Landscape.standardButtonFontSize
            }
        case _ where buttonColor.isScientific:
            return Constants.scientificButtonFontSize
        default:
            break
        }
        assertionFailure(
            "Failed to assign appropriate font size for button color \(buttonColor)." +
            "Will fall back on default system font size.")
        return UIFont.systemFontSize
    }
    
    private struct Constants {
        static let scientificButtonFontSize: CGFloat = 17
        
        struct Portrait {
            static let standardButtonFontSize: CGFloat = 40
            static let standardButtonProminentFontSize: CGFloat = 34
            static let accentButtonFontSize: CGFloat = 34
        }
        struct Landscape {
            static let standardButtonFontSize: CGFloat = 24
            static let standardButtonProminentFontSize: CGFloat = 24
            static let accentButtonFontSize: CGFloat = 22
        }
    }
}

extension ButtonView {
    private static func getBackgroundColors(for configuration: ButtonConfiguration) ->
    (normal: UIColor?, highlighted: UIColor?, selected: UIColor?) {
        var normalBackgroundColor: UIColor? = nil
        var highlightedBackgroundColor: UIColor? = nil
        var selectedBackgroundColor: UIColor? = nil
        
        switch configuration.color {
        case .accentColor:
            normalBackgroundColor = UIColor(named: "ButtonAccentColor")!
            highlightedBackgroundColor = UIColor(named: "ButtonAccentColorHighlighted")!
            selectedBackgroundColor = .white
        case .scientificButtonColor:
            normalBackgroundColor = UIColor(named: "ScientificButtonColor")!
            highlightedBackgroundColor = UIColor(named: "ScientificButtonColorHighlighted")!
            selectedBackgroundColor = UIColor(named: "ScientificButtonColorSelected")!
        case .scientificButtonSelected:
            fatalError("unhandled case") // TODO
        case .standardButtonColor:
            normalBackgroundColor =  UIColor(named: "StandardButtonColor")!
            highlightedBackgroundColor = UIColor(named: "StandardButtonColorHighlighted")!
        case .standardButtonProminent:
            normalBackgroundColor = UIColor(named: "StandardButtonProminentColor")!
            highlightedBackgroundColor = UIColor(named: "StandardButtonProminentColorHighlighted")!
        }
        
        return (normalBackgroundColor, highlightedBackgroundColor, selectedBackgroundColor)
    }
}
