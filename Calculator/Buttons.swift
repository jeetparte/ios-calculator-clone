//
//  Buttons.swift
//  Calculator
//
//  Created by Jeet Parte on 14/02/22.
//

import Foundation

let standardButtonConfigurations: [[ButtonConfiguration]] = [
    // Row 1
    [
        ButtonConfiguration(id: .clear, text: "AC", color: .standardButtonProminent),
        ButtonConfiguration(id: .signChange, text: "plus.forwardslash.minus", color: .standardButtonProminent, textType: .image),
        ButtonConfiguration(id: .percentage, text: "%", color: .standardButtonProminent), //percent
        ButtonConfiguration(id: .division, text: "divide", color: .accentColor, textType: .image),
    ],
    // Row 2
    [
        ButtonConfiguration(id: .seven, text: "7", color: .standardButtonColor),
        ButtonConfiguration(id: .eight, text: "8", color: .standardButtonColor),
        ButtonConfiguration(id: .nine, text: "9", color: .standardButtonColor),
        ButtonConfiguration(id: .multiplication, text: "multiply", color: .accentColor, textType: .image),
    ],
    // Row 3
    [
        ButtonConfiguration(id: .four, text: "4", color: .standardButtonColor),
        ButtonConfiguration(id: .five, text: "5", color: .standardButtonColor),
        ButtonConfiguration(id: .six, text: "6", color: .standardButtonColor),
        ButtonConfiguration(id: .subtraction, text: "minus", color: .accentColor, textType: .image),
    ],
    // Row 4
    [
        ButtonConfiguration(id: .one, text: "1", color: .standardButtonColor),
        ButtonConfiguration(id: .two, text: "2", color: .standardButtonColor),
        ButtonConfiguration(id: .three, text: "3", color: .standardButtonColor),
        ButtonConfiguration(id: .addition, text: "plus", color: .accentColor, textType: .image),
    ],
    // Row 5
    [
        ButtonConfiguration(id: .zero, text: "0", color: .standardButtonColor),
        ButtonConfiguration(id: .decimalPoint, text: ".", color: .standardButtonColor),
        ButtonConfiguration(id: .equals, text: "equal", color: .accentColor, textType: .image),
    ],
]

let scientificButtonConfigurations: [[ButtonConfiguration]] = [
    // Row 1
    [
        ButtonConfiguration(id: .leftParanthesis, text: "(", color: .scientificButtonColor),
        ButtonConfiguration(id: .rightParanthesis, text: ")", color: .scientificButtonColor),
        ButtonConfiguration(id: .mClear, text: "mc", color: .scientificButtonColor),
        ButtonConfiguration(id: .mAdd, text: "m+", color: .scientificButtonColor),
        ButtonConfiguration(id: .mSubtract, text: "m-", color: .scientificButtonColor),
        ButtonConfiguration(id: .mRecall, text: "mr", color: .scientificButtonColor),
    ],
    // Row 2
    [
        ButtonConfiguration(id: .changeButtons, text: "2nd", color: .scientificButtonColor),
        ButtonConfiguration(id: .square, text: "x^2", color: .scientificButtonColor),
        ButtonConfiguration(id: .cube, text: "x^3", color: .scientificButtonColor),
        ButtonConfiguration(id: .power, text: "x^y", color: .scientificButtonColor),
        ButtonConfiguration(id: .exponential, text: "e^x",
                            alternateID: .powerReverseOperands, alternateText: "y^x", color: .scientificButtonColor),
        ButtonConfiguration(id: .powerOfTen, text: "10^x",
                            alternateID: .powerOfTwo, alternateText: "2^x", color: .scientificButtonColor),
    ],
    // Row 3
    [
        ButtonConfiguration(id: .reciprocal, text: "1/x", color: .scientificButtonColor),
        ButtonConfiguration(id: .squareRoot, text: "sqrt", color: .scientificButtonColor),
        ButtonConfiguration(id: .cubeRoot, text: "cbrt", color: .scientificButtonColor),
        ButtonConfiguration(id: .nthRoot, text: "nthRt", color: .scientificButtonColor),
        ButtonConfiguration(id: .naturalLog, text: "Ln",
                            alternateID: .logToTheBase, alternateText: "logY", color: .scientificButtonColor),
        ButtonConfiguration(id: .commonLog, text: "log10",
                            alternateID: .binaryLog, alternateText: "log2", color: .scientificButtonColor),
    ],
    // Row 4
    [
        ButtonConfiguration(id: .factorial, text: "x!", color: .scientificButtonColor),
        ButtonConfiguration(id: .sine, text: "sin", alternateID: .arcsine, alternateText: "sin-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .cosine, text: "cos", alternateID: .arccosine, alternateText: "cos-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .tangent, text: "tan", alternateID: .arctangent, alternateText: "tan-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .eulersConstant, text: "e", color: .scientificButtonColor),
        ButtonConfiguration(id: .enterExponent, text: "EE", color: .scientificButtonColor),
    ],
    // Row 5
    [
        ButtonConfiguration(id: .toggleDegreesOrRadians, text: "Rad" /* or 'Deg' */, color: .scientificButtonColor),
        ButtonConfiguration(id: .hyperbolicSine, text: "sinh", alternateID: .inverseHyperbolicSine, alternateText: "sinh-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .hyperbolicCosine, text: "cosh", alternateID: .inverseHyperbolicCosine, alternateText: "cosh-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .hyperbolicTangent, text: "tanh", alternateID: .inverseHyperbolicTangent, alternateText: "tanh-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .pi, text: "Pi", color: .scientificButtonColor),
        ButtonConfiguration(id: .randomNumber, text: "Rand", color: .scientificButtonColor),
    ],
]
