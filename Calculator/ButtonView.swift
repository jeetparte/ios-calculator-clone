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
    
    init(buttonConfiguration: ButtonConfiguration) {
        self.buttonConfiguration = buttonConfiguration
        
        let backgroundColors = Self.getBackgroundColors(for: buttonConfiguration)
        super.init(normalBackgroundColor: backgroundColors.normal,
                   highlightedBackgroundColor: backgroundColors.highlighted)
                
//        self.layer.borderColor = UIColor.systemRed.cgColor
//        self.layer.borderWidth = 1.0
        
        self.setupSubviews()
        
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(self.tap))
        lp.minimumPressDuration = 0.0
        self.addGestureRecognizer(lp)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.height/2
//        self.layer.cornerCurve = .continuous
    }
    
    @objc func tap(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            self.state = .higlighted
        case .changed:
            break // TODO
        case .ended:
            self.state = .normal
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let label = UILabel()
        label.text = self.showsAlternateKey ? self.buttonConfiguration.alternateText :  self.buttonConfiguration.text
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        self.addSubview(label)
        label.textColor = .lightText // TODO review later
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
