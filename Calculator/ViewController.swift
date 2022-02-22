//
//  ViewController.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit

class ViewController: UIViewController {
    var resultsView: UIView!
    var buttonsGridView: ButtonsGridView!
    
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    
    // MARK: - View events
    override func viewDidLoad() {
        super.viewDidLoad()

        // this app remains in dark mode
        self.view.backgroundColor = .systemBackground
//        self.overrideUserInterfaceStyle = .dark // temp
        
        self.setupSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let orientation = self.view.window?.windowScene?.interfaceOrientation.simpleOrientation {
            self.activateConstraints(for: orientation)
        }
    }
    
    // MARK: - Private methods
    private func setupSubviews() {
        let v = self.view!

        // Buttons grid
        self.buttonsGridView = ButtonsGridView()
        v.addSubview(buttonsGridView)
        
        buttonsGridView.translatesAutoresizingMaskIntoConstraints = false
        let marginsGuide = v.layoutMarginsGuide
        let safeAreaGuide = v.safeAreaLayoutGuide
        
        // Portrait constraints
        let c1 = marginsGuide.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor)
        let c2 = marginsGuide.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor)
        let c3 = safeAreaGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonsGridView.bottomAnchor, multiplier: 5)
        c1.identifier = "c1"
        c2.identifier = "c2"
        c3.identifier = "c3"
        self.portraitConstraints.append(contentsOf: [ c1, c2, c3 ])
        
        // Landscape constraints
        let lc1 = safeAreaGuide.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor, constant: -8.0)
        let lc2 = safeAreaGuide.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor, constant: 8.0)
        let lc3 = safeAreaGuide.bottomAnchor.constraint(equalTo: buttonsGridView.bottomAnchor)
        lc1.identifier = "lc1"
        lc2.identifier = "lc2"
        lc3.identifier = "lc3"
        self.landscapeConstraints.append(contentsOf: [ lc1, lc2, lc3 ])
        
        // Results view
        self.resultsView = UIView()
        v.addSubview(resultsView)
        resultsView.backgroundColor = .systemPurple.withAlphaComponent(0.3)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsView.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor),
            buttonsGridView.topAnchor.constraint(equalToSystemSpacingBelow: resultsView.bottomAnchor, multiplier: 1),
            resultsView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor)
        ])
    }
    
    private func activateConstraints(for orientation: InterfaceOrientation) {
        switch orientation {
        case .portrait:
            NSLayoutConstraint.deactivate(landscapeConstraints)
            self.buttonsGridView.handleOrientationChange(newOrientation: orientation)
            NSLayoutConstraint.activate(portraitConstraints)
        case .landscape:
            NSLayoutConstraint.deactivate(portraitConstraints)
            self.buttonsGridView.handleOrientationChange(newOrientation: orientation)
            NSLayoutConstraint.activate(landscapeConstraints)
        default:
            break
        }
    }

    // MARK: - Misc.
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // Switch between standard and scientific mode on orientation change
        // (hide/show scientific buttons and swap constraints)
        let previousOrientation = self.view.window?.windowScene?.interfaceOrientation
        coordinator.animate { viewControllerTransitionCoordinatorContext in
            let newOrientation = self.view.window?.windowScene?.interfaceOrientation
            
            if newOrientation != previousOrientation {
                guard let newOrientation = newOrientation else { return }
                self.activateConstraints(for: newOrientation.simpleOrientation)
            }
        }
    }
}

