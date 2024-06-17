//
//  WorkSpaceRemoveError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/17/24.
//

import Foundation

struct WorkSpaceRemoveAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E13", "E14"
    ]
    
    var message: String {
        switch errorCode {
        case "E13":
            return "존재하지않는 워크스페이스 입니다."
        case "E14":
            return "워크 스페이스 관리자만 워크 스페이스를 삭제 할수 있습니다."
        default:
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E13":
            return false
        case "E14":
            return false
        default:
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
