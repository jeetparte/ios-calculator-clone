//
//  ViewController.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ViewController: UIViewController {
    var resultsView: UIView!
    var buttonsStackView: UIStackView!
    
    override func loadView() {
        let v = UIView()
        self.view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
//        self.overrideUserInterfaceStyle = .dark
        
        let v = self.view!
        self.buttonsStackView = UIStackView()
        v.addSubview(buttonsStackView)
        buttonsStackView.backgroundColor = .systemMint
        
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        let marginsGuide = v.layoutMarginsGuide
        NSLayoutConstraint.activate([
            marginsGuide.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            marginsGuide.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor),
            marginsGuide.bottomAnchor.constraint(equalTo: buttonsStackView.bottomAnchor),
            
            buttonsStackView.heightAnchor.constraint(equalTo: marginsGuide.heightAnchor, multiplier: 0.65) // might want to tweak this for landscape orientation
        ])
        
        self.resultsView = UIView()
        v.addSubview(resultsView)
        resultsView.backgroundColor = .systemPurple
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsView.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalToSystemSpacingBelow: resultsView.bottomAnchor, multiplier: 1),
            resultsView.topAnchor.constraint(equalTo: marginsGuide.topAnchor)
        ])
    }


}

