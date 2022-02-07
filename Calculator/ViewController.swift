//
//  ViewController.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ViewController: UIViewController {
    var resultsView: UIView!
    var buttonsGridView: UIStackView!
    
    override func loadView() {
        let v = UIView()
        self.view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
//        self.overrideUserInterfaceStyle = .dark
        
        let v = self.view!
        self.buttonsGridView = ButtonsGridView()
        v.addSubview(buttonsGridView)
        buttonsGridView.backgroundColor = .systemMint
        
        buttonsGridView.translatesAutoresizingMaskIntoConstraints = false
        let marginsGuide = v.layoutMarginsGuide
        NSLayoutConstraint.activate([
            marginsGuide.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor),
            marginsGuide.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor),
            marginsGuide.bottomAnchor.constraint(equalTo: buttonsGridView.bottomAnchor),
            
            buttonsGridView.heightAnchor.constraint(equalTo: marginsGuide.heightAnchor, multiplier: 0.65) // might want to tweak this for landscape orientation
        ])
        
        self.resultsView = UIView()
        v.addSubview(resultsView)
        resultsView.backgroundColor = .systemPurple
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsView.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor),
            buttonsGridView.topAnchor.constraint(equalToSystemSpacingBelow: resultsView.bottomAnchor, multiplier: 1),
            resultsView.topAnchor.constraint(equalTo: marginsGuide.topAnchor)
        ])
    }


}

