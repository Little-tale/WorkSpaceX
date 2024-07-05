//
//  WorkSpaceMembersAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import Foundation

struct WorkSpaceMembersAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E13"
    ]
    
    var message: String {
        if errorCode == "E13" {
            return "존재하지 않는 워크스페이스 혹은 유저 입니다."
        } else {
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
