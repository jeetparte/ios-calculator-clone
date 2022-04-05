//
//  ViewController.swift
//  Calculator
//
//  Created by Jeet Parte on 07/02/22.
//

import UIKit
import CalculatorCore

class ViewController: UIViewController {
    let calculator = SingleStepCalculator()
    
    var displayLabel: UILabel!
    var resultsView: UIView!
    var buttonsGridView: ButtonsGridView!
    
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    
    var appearedOnce = false
    
    // MARK: - View events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // listen for button tap notifications
        NotificationCenter.default
            .addObserver(self, selector: #selector(self.handleButtonTap(_:)), name: SharedConstants.buttonWasPressed, object: nil)

        // this app remains in dark mode
        self.view.backgroundColor = .systemBackground
        self.overrideUserInterfaceStyle = .dark
        
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
    
    // MARK: - Handle button taps
    var displayNumber: Double = 0 {
        didSet {
            displayLabel.text =
            // TODO: - avoid creating a new formatter instance every time.
            NumberFormatter.localizedString(from: NSNumber(value: self.displayNumber), number: .decimal)
        }
    }
    var operationToSelect: ButtonID? {
        didSet {
            guard operationToSelect != oldValue else { return }
            NotificationCenter.default.post(name: SharedConstants.selectedBinaryOperationChanged, object: self, userInfo: [SharedConstants.selectedBinaryOperationUserInfoKey: operationToSelect as Any])
        }
    }
        
    @objc func handleButtonTap(_ notification: Notification) {
        guard let buttonView = notification.object as? ButtonView else { return }
//        print("handling tap for button \(buttonView.currentId)")
        
        switch buttonView.currentId {
        case .digit(let n):
            try! calculator.inputDigit(n)
        case .decimalPoint:
            calculator.insertDecimalPoint()
        case .clear:
            calculator.allClear()
        case .signChange:
            calculator.inputOperation(.signChange)
        case .percentage:
            calculator.inputOperation(.percentage)
        case let x where x.isBinaryOperator:
            let operation = binaryOperationsMap[x]!
            calculator.inputOperation(operation)
        case .equals:
            calculator.evaluate()
        case .mAdd, .mSubtract, .mClear:
            let function = memoryOperationsMap[buttonView.currentId]!
            calculator.performMemoryFunction(function)
        case .mRecall:
            calculator.recallMemory()
        case .changeButtons:
            self.changeButtons()
            buttonView.toggleSelection()
        default:
            break
        }
        displayNumber = calculator.displayValue ?? -1.0
        self.updateCurrentOperation(buttonView.currentId)
        self.updateMemoryRecallButtonSelectionState(buttonView.currentId)
    }
    
    private func changeButtons() {
        let candidates = buttonsGridView.allScientificButtons.flatMap {$0}.compactMap { $0 as? ButtonView }
        candidates.forEach {
            $0.shouldShowAlternate.toggle()
        }
    }
    
    private func updateMemoryRecallButtonSelectionState(_ id: ButtonID) {
        if id == .mClear {
            // remove background highlight
            postNotification(shouldSelect: false)
        } else if id == .mAdd || id == .mSubtract {
            // activate background highlight
            postNotification(shouldSelect: true)
        }
        
        func postNotification(shouldSelect: Bool) {
            NotificationCenter.default.post(name: SharedConstants.shouldChangeMemoryRecallButtonSelectionState, object: self, userInfo: [SharedConstants.shouldSelectMemoryRecallButton : shouldSelect])
        }
    }
    
    private func updateCurrentOperation(_ id: ButtonID) {
        // if this was one of the binary operations,
        // show the corresponding button in 'selected' state
        if id.isBinaryOperator {
            self.operationToSelect = newOperation()
        } else if calculator.operation == nil {
            self.operationToSelect = nil
        } else {
            // we unselect the previously selected operation button on
            // receiving certain inputs
            if case .digit(_) = id {
                self.operationToSelect = nil
            }
            if id == .decimalPoint {
                self.operationToSelect = nil
            }
        }
        
        func newOperation() -> ButtonID? {
            guard let operation = calculator.operation else { return nil }
            // Ideally, we'd want a bi-directional map here.
            // But this is ok for now.
            return binaryOperationsMap
                .first { $0.value == operation }!
                .key
        }
    }
    
    private var binaryOperationsMap: [ButtonID: SingleStepCalculator.BinaryOperation] = [
        .division: .divide,
        .multiplication: .multiply,
        .subtraction: .subtract,
        .addition: .add,
        .power: .power,
        .powerReverseOperands: .powerReverseOperands,
        .logToTheBase: .logToTheBase
    ]
    
    private var memoryOperationsMap: [ButtonID: SingleStepCalculator.MemoryFunction] = [
        .mAdd: .add,
        .mSubtract: .subtract,
        .mClear: .clear
    ]
    
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
        self.setupDisplayLabel()
    }
    
    private func setupDisplayLabel() {
        self.displayLabel = UILabel()
        self.resultsView.addSubview(displayLabel)
        
        // TODO fix issue on landscape, label is wider than it needs to be
//        displayLabel.backgroundColor = .systemYellow // debugging
        displayLabel.textAlignment = .right // makes it a bit better
        
        displayLabel.adjustsFontSizeToFitWidth = true
        displayLabel.minimumScaleFactor = 0.5 // tweak later
                
        displayLabel.text = NumberFormatter.localizedString(from: NSNumber(value: self.displayNumber), number: .decimal)
        displayLabel.textColor = .white
        displayLabel.font = UIFont.systemFont(ofSize: 86, weight: .light)
        
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // TODO might want to vary constraints for landscape vs portrait
            displayLabel.trailingAnchor.constraint(equalTo: resultsView.trailingAnchor, constant: -8),
            displayLabel.bottomAnchor.constraint(equalTo: resultsView.bottomAnchor, constant: -8),
            displayLabel.leadingAnchor.constraint(greaterThanOrEqualTo: resultsView.leadingAnchor, constant: 8),
            displayLabel.topAnchor.constraint(greaterThanOrEqualTo: resultsView.topAnchor, constant: 0)
        ])
    }
    
    private func activateConstraints(for orientation: InterfaceOrientation) {
//         FIXME: - Maybe ripping out the stack view temporarily can help get rid of the auto-layout warning?
        // Yes it works, but it creates other problems - some constraints are lost TODO: confirm this
        
        switch orientation {
        case .portrait:
            NSLayoutConstraint.deactivate(landscapeConstraints)
            self.buttonsGridView.handleOrientationChange(newOrientation: orientation)
            NSLayoutConstraint.activate(portraitConstraints)
        case .landscape:
            NSLayoutConstraint.deactivate(portraitConstraints)
//            self.buttonsGridView.removeFromSuperview()
            self.buttonsGridView.handleOrientationChange(newOrientation: orientation)
//            self.view.addSubview(self.buttonsGridView)
            NSLayoutConstraint.activate(landscapeConstraints)
            self.view.layoutIfNeeded()
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

