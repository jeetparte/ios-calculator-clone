//
//  ButtonView.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ButtonView: HighlightableBackgroundView {
    var buttonConfiguration: ButtonConfiguration
    
    var showsAlternateKey: Bool = false // default
    
    var label: UILabel!
    
    init(buttonConfiguration: ButtonConfiguration) {
        self.buttonConfiguration = buttonConfiguration
        
        // set the background for various states
        let backgroundColors = Self.getBackgroundColors(for: buttonConfiguration)
        super.init(normalBackgroundColor: backgroundColors.normal,
                   highlightedBackgroundColor: backgroundColors.highlighted)
                
//        self.layer.borderColor = UIColor.systemRed.cgColor
//        self.layer.borderWidth = 1.0
        
        self.initializeLabel()
        // update label whenever an orientation change notification is posted
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLabel(_:)), name: ButtonsGridView.SharedConstants.orientationChangeNotificationName, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.height/2
//        self.layer.cornerCurve = .continuous
    }
    
    func buttonTap() {
        print("tapped \(self.buttonConfiguration.text)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeLabel() {
        let label = UILabel()
        self.label = label
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        label.text = self.showsAlternateKey ? self.buttonConfiguration.alternateText :  self.buttonConfiguration.text
        label.textColor = self.buttonConfiguration.color == .standardButtonProminent ? .black : .white
    }
    
    var previousFontSize: CGFloat?
    @objc func updateLabel(_ orientationChangeNotification: Notification) {
        guard let userInfo = orientationChangeNotification.userInfo,
              let newOrientation = userInfo[ButtonsGridView.SharedConstants.newOrientationUserInfoKey] as?
                InterfaceOrientation else {
                    assertionFailure(
                        "An orientation-change notification was posted without information about the new orientation. " +
                        "Cannot decide buttons' label appearance for unknown orientation.")
                    return
                }
        
        let fontSize = Self.getFontSize(for: buttonConfiguration.color, orientation: newOrientation)
        if self.previousFontSize == nil {
            // setting font for the first time
            
            let weight: UIFont.Weight =
            [.standardButtonProminent, .accentColor]
                .contains(self.buttonConfiguration.color) ? .medium : .regular
            self.label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
            self.previousFontSize = fontSize
            return
        }
        
        guard fontSize != self.previousFontSize else { return }
        // visually, the font size changes abruptly, so we use this transition animation to smooth it out
        UIView.transition(with: label, duration: 0.0, options: [.transitionCrossDissolve]) {
            self.label.font = self.label.font.withSize(fontSize)
        }
        self.previousFontSize = fontSize
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
        static let scientificButtonFontSize: CGFloat = 16
        
        struct Portrait {
            static let standardButtonFontSize: CGFloat = 40
            static let standardButtonProminentFontSize: CGFloat = 34
        }
        struct Landscape {
            static let standardButtonFontSize: CGFloat = 24
            static let standardButtonProminentFontSize: CGFloat = 24
        }
    }
}

extension ButtonView {
    private static func getBackgroundColors(for configuration: ButtonConfiguration) ->
    (normal: UIColor?, highlighted: UIColor?) {
        var normalBackgroundColor: UIColor? = nil
        var highlightedBackgroundColor: UIColor? = nil
        
        switch configuration.color {
        case .accentColor:
            normalBackgroundColor = UIColor(named: "ButtonAccentColor")!
            highlightedBackgroundColor = UIColor(named: "ButtonAccentColorHighlighted")!
        case .scientificButtonColor:
            normalBackgroundColor = UIColor(named: "ScientificButtonColor")!
            highlightedBackgroundColor = UIColor(named: "ScientificButtonColorHighlighted")!
        case .scientificButtonSelected:
            fatalError("unhandled case") // TODO
        case .standardButtonColor:
            normalBackgroundColor =  UIColor(named: "StandardButtonColor")!
            highlightedBackgroundColor = UIColor(named: "StandardButtonColorHighlighted")!
        case .standardButtonProminent:
            normalBackgroundColor = UIColor(named: "StandardButtonProminentColor")!
            highlightedBackgroundColor = UIColor(named: "StandardButtonProminentColorHighlighted")!
        }
        
        return (normalBackgroundColor, highlightedBackgroundColor)
    }
}
