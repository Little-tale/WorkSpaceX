//
//  WorkSpaceEditError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/18/24.
//

import Foundation

struct WorkSpaceEditAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11", "E12", "E13", "E14"
    ]
    
    var message: String {
        switch errorCode {
        case "E12" :
            return "수정 사항이 없습니다."
        case "E13" :
            return "워크스페이스가 존재 하지 않습니다."
        case "E11" :
            return "수정 사항이 없습니다."
        case "E14" :
            return "수정 궈한이 없습니다."
        default :
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E11", "E12", "E13", "E14":
            return false
        default:
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
