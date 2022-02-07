//
//  ViewController.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ViewController: UIViewController {
    
    override func loadView() {
        let v = UIView()
        self.view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        self.overrideUserInterfaceStyle = .dark
    }


}

