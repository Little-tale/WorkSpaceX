//
//  WorkSpaceExitError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import Foundation

struct WorkSpaceExitError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E13", "E15"]
    
    var message: String {
        switch errorCode {
        case "E13":
            return "존재 하지 않는 워크 스페이스 입니다."
        case "E15":
            return "워크스페이스 관리자 혹은 채널 관리자는\n퇴장 하실수 없습니다."
        default:
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E13":
            return false
        case "E15":
            return false
        default:
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
    
}
