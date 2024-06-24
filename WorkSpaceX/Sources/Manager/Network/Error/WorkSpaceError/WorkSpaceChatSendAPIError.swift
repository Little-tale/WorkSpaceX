//
//  WorkSpaceChatSendAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/24/24.
//

import Foundation

struct WorkSpaceChatSendAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11", "E13"
    ]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청입니다."
        case "E13":
            return "존재하지 않는 채널 혹은 워크스페이스 입니다."
        default:
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E11":
            return false
        case "E13":
            return false
        default:
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
    
}
