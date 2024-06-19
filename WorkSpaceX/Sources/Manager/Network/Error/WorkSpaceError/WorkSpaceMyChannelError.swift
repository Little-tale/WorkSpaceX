//
//  WorkSpaceMyChannelError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import Foundation

struct WorkSpaceMyChannelError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E13"
    ]
    
    var message: String {
        switch errorCode {
        case "E13":
            return "해당 워크스페이스를 찾을수 없습니다..."
        default :
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        if errorCode == "E13" {
            return false
        } else {
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
