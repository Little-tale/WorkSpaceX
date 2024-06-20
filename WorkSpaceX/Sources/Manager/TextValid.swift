//
//  TextValid.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import Foundation
import ComposableArchitecture

struct TextValid {
    
    static func TextValidate(_ text: String, caseOf: RegularExpressionCase) -> textValidation {
        if text.isEmpty { return .isEmpty }
        return caseOf.matchesPattern(text)
    }
    
    static func phoneTextValiate(_ text: String) -> String {
        if text.isEmpty { return "" }
        return RegularExpressionCase.phoneNumber.formatterPhoneNumber(text)
    }
    
}

extension TextValid : DependencyKey {
    static var liveValue: TextValid = Self()
}

extension DependencyValues {
    
    var textValidtor: TextValid {
        get { self[TextValid.self] }
        set { self[TextValid.self] = newValue }
    }
    
}
