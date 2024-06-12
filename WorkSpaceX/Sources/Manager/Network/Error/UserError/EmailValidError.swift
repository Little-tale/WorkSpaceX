//
//  EmailValidError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation


struct EmailValidError: WSXErrorType {
    
    var errorCode: String
    
    private(set) var thisErrorCodes = [
        "E11", "E12"
    ]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청을 하고 있습니다."
        case "E12":
            return "중복된 이메일입니다."
        default:
            return "알 수 없는 에러입니다."
        }
    }
    
    var ifDevelopError: Bool {
        return errorCode == "E11"
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
