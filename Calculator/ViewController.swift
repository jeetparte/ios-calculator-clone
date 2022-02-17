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
        
        // show safe area
//        let v = self.view!
//        let safeAreaView = UIView()
//        safeAreaView.backgroundColor = .systemBlue
//        v.insertSubview(safeAreaView, at: 0)
//        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            safeAreaView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor),
//            safeAreaView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor),
//            safeAreaView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor),
//            safeAreaView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor),
//        ])
        
        self.setupSubviews()
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
        
        self.portraitConstraints.append(contentsOf: [
            marginsGuide.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor),
            marginsGuide.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor),
            safeAreaGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonsGridView.bottomAnchor, multiplier: 5),
        ])
        
        self.landscapeConstraints.append(contentsOf: [
            safeAreaGuide.leadingAnchor.constraint(equalTo: buttonsGridView.leadingAnchor, constant: -8.0),
            safeAreaGuide.trailingAnchor.constraint(equalTo: buttonsGridView.trailingAnchor, constant: 8.0),
            safeAreaGuide.bottomAnchor.constraint(equalTo: buttonsGridView.bottomAnchor)
        ])

        self.activateConstraints(for: self.traitCollection.phoneInterfaceOrientation)
        
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
        // first deactivate current constraints!
        switch orientation {
        case .portrait:
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        case .landscape:
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        default:
            break
        }
    }

    // MARK: - Misc.
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        // Switch between standard and scientific mode on orientation change
        // (hide/show scientific buttons and swap constraints)
        
        let currentSizeClasses = (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
        let newSizeClasses = (newCollection.horizontalSizeClass, newCollection.verticalSizeClass)
        
        let orientationWillChange = newSizeClasses != currentSizeClasses
        guard orientationWillChange else { return }
        
        coordinator.animate { viewControllerTransitionCoordinatorContext in
            let newOrientation = newCollection.phoneInterfaceOrientation
            self.activateConstraints(for: newOrientation)
            self.buttonsGridView.handleOrientationChange(newOrientation: newOrientation)
        }
    }
}

