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
    
    var showsAlternateKey: Bool = false // default
    
    var label: UILabel!
    var imageView: UIImageView!
    
    private var previousFontSize: CGFloat?
    
    private var normalForegroundColor: UIColor? {
        return self.buttonConfiguration.color == .standardButtonProminent ? .black : .white
    }
    
    override var visualState: HighlightableBackgroundView.VisualState {
        didSet {
            guard visualState != oldValue else { return }
            
            // change foreground color when selected or unselected
            switch (oldValue, visualState) {
            case (_, .selected):
                // Change foreground color to normal variant of background color
                if let selectedTextColor = self.stateBackgroundColorMap[.normal], selectedTextColor != nil {
                    label?.textColor = selectedTextColor!
                    imageView?.tintColor = selectedTextColor!
                }
            case (_, .normal):
                // Revert foreground color to previous state
                label?.textColor = normalForegroundColor
                imageView?.tintColor = normalForegroundColor
            default:
                break
            }
        }
    }
    
    init(buttonConfiguration: ButtonConfiguration) {
        self.buttonConfiguration = buttonConfiguration
        self.id = buttonConfiguration.id
        
        // set the background for various states
        let backgroundColors = Self.getBackgroundColors(for: buttonConfiguration)
        super.init(normalBackgroundColor: backgroundColors.normal,
                   highlightedBackgroundColor: backgroundColors.highlighted)
                
//        self.layer.borderColor = UIColor.systemRed.cgColor
//        self.layer.borderWidth = 1.0
        
        switch buttonConfiguration.textType {
        // TODO both of these are very similar; can we merge them?
        case .image:
            self.initializeImage()
            // update image whenever an orientation change notification is posted
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateImage(_:)), name: SharedConstants.orientationChangedNotification, object: nil)
        case .label:
            self.initializeLabel()
            // update label whenever an orientation change notification is posted
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateLabel(_:)), name: SharedConstants.orientationChangedNotification, object: nil)
        }
        
        if self.id.isBinaryOperator {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeBinaryOperation(_:)), name: SharedConstants.binaryOperationChanged, object: nil)
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
    
    // MARK: - Label
    private func initializeLabel() {
        let label = UILabel()
        self.label = label
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        label.text = self.showsAlternateKey ? self.buttonConfiguration.alternateText :  self.buttonConfiguration.text
        label.textColor = self.normalForegroundColor
    }
    
    @objc func updateLabel(_ orientationChangeNotification: Notification) {
        guard let userInfo = orientationChangeNotification.userInfo,
              let newOrientation = userInfo[SharedConstants.newOrientationUserInfoKey] as?
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
    
    //MARK: - Image
    private func initializeImage() {
        let imageView = UIImageView()
        self.imageView = imageView
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                
        imageView.image = UIImage(systemName: buttonConfiguration.text)
        imageView.tintColor  = self.normalForegroundColor
    }
    
    @objc func updateImage(_ orientationChangeNotification: Notification) {
        guard let userInfo = orientationChangeNotification.userInfo,
              let newOrientation = userInfo[SharedConstants.newOrientationUserInfoKey] as?
                InterfaceOrientation else {
                    assertionFailure(
                        "An orientation-change notification was posted without information about the new orientation. " +
                        "Cannot decide buttons' image appearance for unknown orientation.")
                    return
                }
        
        let fontSize = Self.getFontSize(for: buttonConfiguration.color, orientation: newOrientation)
        if self.previousFontSize == nil {
            // setting font for the first time
            let weight: UIFont.Weight =
            [.standardButtonProminent, .accentColor]
                .contains(self.buttonConfiguration.color) ? .medium : .regular
            self.imageView.preferredSymbolConfiguration = .init(pointSize: fontSize, weight: weight.symbolWeight(), scale: .medium)
            self.previousFontSize = fontSize
            return
        }
        
        guard fontSize != self.previousFontSize else { return }
        // visually, the font size changes abruptly, so we use this transition animation to smooth it out
        UIView.transition(with: imageView, duration: 0.0, options: [.transitionCrossDissolve]) {
            let newConfiguration = UIImage.SymbolConfiguration(pointSize: fontSize)
            self.imageView.preferredSymbolConfiguration = self.imageView.preferredSymbolConfiguration?.applying(newConfiguration)
        }
        self.previousFontSize = fontSize
    }
    
    // MARK: - Binary operators
    @objc func didChangeBinaryOperation(_ binaryOperationChangedNotification: Notification) {
        guard let userInfo = binaryOperationChangedNotification.userInfo,
              let infoUnderKey = userInfo[SharedConstants.binaryOperationUserInfoKey],
              let newOperation =  infoUnderKey as? ButtonID? else {
            assertionFailure("Could not obtain necessary information from notification")
            return
        }
        
        // Highlight the operation button (e.g. +, -, *, / etc.) that is currently selected
        if self.id == newOperation {
            self.visualState = .selected
        } else {
            self.visualState = .normal
        }
    }
    
    // MARK: -
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
        static let scientificButtonFontSize: CGFloat = 16
        
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
