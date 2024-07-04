//
//  UserEditAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import Foundation

struct UserEditAPIError: WSXErrorType {
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E13"]
    
    var message: String {
        if errorCode == "E13" {
            return "잘못된 요청입니다."
        } else {
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        return !thisErrorCodes.contains { $0 == errorCode }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
