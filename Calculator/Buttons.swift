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
        ButtonConfiguration(id: .unary(.signChange), text: "plus.forwardslash.minus", color: .standardButtonProminent, textType: .image),
        ButtonConfiguration(id: .unary(.percentage), text: "%", color: .standardButtonProminent), //percent
        ButtonConfiguration(id: .binary(.divide), text: "divide", color: .accentColor, textType: .image),
    ],
    // Row 2
    [
        ButtonConfiguration(id: .digit(7), text: "7", color: .standardButtonColor),
        ButtonConfiguration(id: .digit(8), text: "8", color: .standardButtonColor),
        ButtonConfiguration(id: .digit(9), text: "9", color: .standardButtonColor),
        ButtonConfiguration(id: .binary(.multiply), text: "multiply", color: .accentColor, textType: .image),
    ],
    // Row 3
    [
        ButtonConfiguration(id: .digit(4), text: "4", color: .standardButtonColor),
        ButtonConfiguration(id: .digit(5), text: "5", color: .standardButtonColor),
        ButtonConfiguration(id: .digit(6), text: "6", color: .standardButtonColor),
        ButtonConfiguration(id: .binary(.subtract), text: "minus", color: .accentColor, textType: .image),
    ],
    // Row 4
    [
        ButtonConfiguration(id: .digit(1), text: "1", color: .standardButtonColor),
        ButtonConfiguration(id: .digit(2), text: "2", color: .standardButtonColor),
        ButtonConfiguration(id: .digit(3), text: "3", color: .standardButtonColor),
        ButtonConfiguration(id: .binary(.add), text: "plus", color: .accentColor, textType: .image),
    ],
    // Row 5
    [
        ButtonConfiguration(id: .digit(0), text: "0", color: .standardButtonColor),
        ButtonConfiguration(id: .decimalPoint, text: ".", color: .standardButtonColor),
        ButtonConfiguration(id: .equals, text: "equal", color: .accentColor, textType: .image),
    ],
]

let scientificButtonConfigurations: [[ButtonConfiguration]] = [
    // Row 1
    [
        ButtonConfiguration(id: .leftParanthesis, text: "(", color: .scientificButtonColor),
        ButtonConfiguration(id: .rightParanthesis, text: ")", color: .scientificButtonColor),
        ButtonConfiguration(id: .memoryFunction(.clear), text: "mc", color: .scientificButtonColor),
        ButtonConfiguration(id: .memoryFunction(.add), text: "m+", color: .scientificButtonColor),
        ButtonConfiguration(id: .memoryFunction(.subtract), text: "m-", color: .scientificButtonColor),
        ButtonConfiguration(id: .memoryRecall, text: "mr", color: .scientificButtonColor),
    ],
    // Row 2
    [
        ButtonConfiguration(id: .changeButtons, text: "2nd", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.square), text: "x^2", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.cube), text: "x^3", color: .scientificButtonColor),
        ButtonConfiguration(id: .binary(.power), text: "x^y", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.exponential), text: "e^x",
                            alternateID: .binary(.powerReverseOperands), alternateText: "y^x", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.powerOfTen), text: "10^x",
                            alternateID: .unary(.powerOfTwo), alternateText: "2^x", color: .scientificButtonColor),
    ],
    // Row 3
    [
        ButtonConfiguration(id: .unary(.reciprocal), text: "1/x", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.squareRoot), text: "sqrt", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.cubeRoot), text: "cbrt", color: .scientificButtonColor),
        ButtonConfiguration(id: .binary(.nthRoot), text: "nthRt", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.naturalLog), text: "Ln",
                            alternateID: .binary(.logToTheBase), alternateText: "logY", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.commonLog), text: "log10",
                            alternateID: .unary(.binaryLog), alternateText: "log2", color: .scientificButtonColor),
    ],
    // Row 4
    [
        ButtonConfiguration(id: .unary(.factorial), text: "x!", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.sine), text: "sin", alternateID: .unary(.arcsine), alternateText: "sin-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.cosine), text: "cos", alternateID: .unary(.arccosine), alternateText: "cos-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.tangent), text: "tan", alternateID: .unary(.arctangent), alternateText: "tan-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .specialInput(.eulersConstant), text: "e", color: .scientificButtonColor),
        ButtonConfiguration(id: .binary(.enterExponent), text: "EE", color: .scientificButtonColor),
    ],
    // Row 5
    [
        ButtonConfiguration(id: .specialInput(.toggleDegreesOrRadians), text: "Rad" /* or 'Deg' */, color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.hyperbolicSine), text: "sinh", alternateID: .unary(.inverseHyperbolicSine), alternateText: "sinh-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.hyperbolicCosine), text: "cosh", alternateID: .unary(.inverseHyperbolicCosine), alternateText: "cosh-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .unary(.hyperbolicTangent), text: "tanh", alternateID: .unary(.inverseHyperbolicTangent), alternateText: "tanh-1", color: .scientificButtonColor),
        ButtonConfiguration(id: .specialInput(.pi), text: "Pi", color: .scientificButtonColor),
        ButtonConfiguration(id: .specialInput(.randomNumber), text: "Rand", color: .scientificButtonColor),
    ],
]
