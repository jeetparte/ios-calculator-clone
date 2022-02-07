//
//  ButtonsView.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ButtonsGridView: UIStackView {

    init() {
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .fill
        self.spacing = UIStackView.spacingUseSystem
        self.setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let rowCount = 5
        for _ in 0..<rowCount {
            let row = UIStackView()
            row.backgroundColor = .systemGray
            row.axis = .horizontal
            row.alignment = .center
            
            self.addArrangedSubview(row)
        }
    }
    
}
