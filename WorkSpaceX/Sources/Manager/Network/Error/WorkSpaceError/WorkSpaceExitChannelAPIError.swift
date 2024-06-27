//
//  WorkSpaceExitChannelAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/27/24.
//

import Foundation

struct WorkSpaceExitChannelAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E13", "E15", "E11"
    ]
    
    var message: String {
        switch errorCode {
        case "E13":
            return "존재하지 않는 워크 스페이스 혹은 채널입니다."
        case "E15":
            return "채널 관리자는 권한 양도후 퇴장이 가능합니다."
        case "E11":
            return "기본 채널은 최장하실수 없습니다."
        default:
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
