//
//  WorkSpaceMakeChannelAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import Foundation

struct WorkSpaceMakeChannelAPIError: WSXErrorType {
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11","E12","E13"
    ]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청입니다."
        case "E12":
            return "중복된 채널 입니다."
        case "E13":
            return "워크 스페이스를 찾을수 없어요."
        default :
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E11":
            return true
        case "E12":
            return false
        case "E13":
            return false
        default :
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
