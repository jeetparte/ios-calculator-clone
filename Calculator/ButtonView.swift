//
//  ButtonView.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ButtonView: UIButton {
    var buttonConfiguration: ButtonConfiguration
    
    var showsAlternateKey: Bool = false // default
    
    init(buttonConfiguration: ButtonConfiguration) {
        self.buttonConfiguration = buttonConfiguration
        
        super.init(frame: .zero)
        
        self.backgroundColor = .systemGray2
        
//        self.layer.borderColor = UIColor.systemRed.cgColor
//        self.layer.borderWidth = 1.0
        
        self.setupSubviews()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tapGR)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.height/2
//        self.layer.cornerCurve = .continuous
    }
    
    @objc func tap() {
        print("tapped \(buttonConfiguration.text)")
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
