//
//  ButtonForegroundTextView.swift
//  Calculator
//
//  Created by Jeet Parte on 04/04/22.
//

import Foundation
import UIKit

// This exists so that the actual button (i.e. client) does not have to bother with the underlying foreground view type
class ButtonForegroundProvider {
    private var label: UILabel!
    private var imageView: UIImageView!
    
    private var textType: ButtonTextType
    private var buttonConfiguration: ButtonConfiguration
    
    private var normalForegroundColor: UIColor? {
        return self.buttonConfiguration.color == .standardButtonProminent ? .black : .white
    }
    
    init(buttonConfiguration: ButtonConfiguration) {
        self.buttonConfiguration = buttonConfiguration
        self.textType = buttonConfiguration.textType
        self.initializeViews()
    }
    
    private func initializeViews() {
        switch self.textType {
        case .label:
            self.label = UILabel()
            label.text = self.buttonConfiguration.text
            label.textColor = self.normalForegroundColor
        case .image:
            self.imageView = UIImageView()
            imageView.image = UIImage(systemName: buttonConfiguration.text)
            imageView.tintColor  = self.normalForegroundColor
        }
    }
    
    func getView() -> UIView {
        switch self.textType {
        case .label:
            return self.label!
        case .image:
            return self.imageView!
        }
    }
    
    func setTextColor(_ color: UIColor?) {
        self.label?.textColor = color ?? normalForegroundColor
        self.imageView?.tintColor = color ?? normalForegroundColor
    }
    
    func setFont(size fontSize: CGFloat, weight: UIFont.Weight) {
        self.label?.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        self.imageView?.preferredSymbolConfiguration = .init(pointSize: fontSize, weight: weight.symbolWeight(), scale: .medium)
    }
    
    func updateFont(size fontSize: CGFloat) {
        self.label?.font = self.label.font.withSize(fontSize)
        if let imageView = self.imageView {
            let newConfiguration = UIImage.SymbolConfiguration(pointSize: fontSize)
            imageView.preferredSymbolConfiguration = imageView.preferredSymbolConfiguration?.applying(newConfiguration)
        }        
    }
}
