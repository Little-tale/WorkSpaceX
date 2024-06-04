//
//  TextValid.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import Foundation

struct TextValid {
    
    func TextValidate(_ text: String, caseOf: RegularExpressionCase) -> textValidation {
        if text.isEmpty { return .isEmpty }
        return caseOf.matchesPattern(text)
    }
    
    func phoneTextValiate(_ text: String) -> String {
        if text.isEmpty { return "" }
        return RegularExpressionCase.phoneNumber.formatterPhoneNumber(text)
    }
    
}
