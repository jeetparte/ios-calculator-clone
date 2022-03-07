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
    
    var appearedOnce = false
    
    // MARK: - View events
    override func viewDidLoad() {
        super.viewDidLoad()

        // this app remains in dark mode
        self.view.backgroundColor = .systemBackground
//        self.overrideUserInterfaceStyle = .dark // temp
        
        self.setupSubviews()
    }
        
    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppear")
        super.viewDidAppear(animated)
        
        guard !appearedOnce else { return }
        
        // just do this the first time
        if !appearedOnce {
            appearedOnce = true

            // Check if this is an older device (with bezel)
            if let safeAreaInsets = self.view.window?.safeAreaInsets {
//                print(safeAreaInsets)
                if safeAreaInsets.bottom == 0 {
                    // older device, layout closer to screen bottom
                    self.setupConstraints(bezelDevice: true)
                } else {
                    self.setupConstraints(bezelDevice: false)
                }
            }
            
            assert(self.view.window?.windowScene != nil, "Pretty important initialization code depends on this.")
            if let orientation = self.view.window?.windowScene?.interfaceOrientation.simpleOrientation {
                self.activateConstraints(for: orientation)
            }
        }
    }
    
    // MARK: - Private methods
    private func setupConstraints(bezelDevice: Bool = false) {
        let v = self.view!
        let safeAreaGuide = v.safeAreaLayoutGuide
        buttonsGridView.translatesAutoresizingMaskIntoConstraints = false

        if bezelDevice {
            let leading = self.view.leadingAnchor.constraint(equalTo: self.buttonsGridView.leadingAnchor, constant: -10)
            let trailing = self.view.trailingAnchor.constraint(equalTo: self.buttonsGridView.trailingAnchor, constant: 10)
            let bottom = self.view.bottomAnchor.constraint(equalTo: self.buttonsGridView.bottomAnchor, constant: 10)
            leading.identifier = "bezel-leading"
            trailing.identifier = "bezel-trailing"
            bottom.identifier = "bezel-bottom"
            
            NSLayoutConstraint.activate([leading, trailing, bottom])
        } else {
            // Portrait constraints
            let c1 = safeAreaGuide.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor, constant: -16)
            let c2 = safeAreaGuide.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor, constant: 16)
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
        }
    }
    
    
    private func setupSubviews() {
        let v = self.view!

        // Buttons grid
        self.buttonsGridView = ButtonsGridView()
        buttonsGridView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(buttonsGridView)
        
        // Results view
        self.resultsView = UIView()
        v.addSubview(resultsView)
//        resultsView.backgroundColor = .systemPurple.withAlphaComponent(0.3)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsView.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor),
            buttonsGridView.topAnchor.constraint(equalToSystemSpacingBelow: resultsView.bottomAnchor, multiplier: 1),
            resultsView.topAnchor.constraint(equalTo: v.safeAreaLayoutGuide.topAnchor)
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

