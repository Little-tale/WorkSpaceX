//
//  ChannelOwnerChangedAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/30/24.
//

import Foundation

struct ChannelOwnerChangedAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11", "E13", "E14"
    ]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청입니다."
        case "E13":
            return "존재 하지 않는 워크 스페이스 혹은 채널 입니다."
        case "E14":
            return "채널 관리자만 채널에 대한 권한을 양도 가능합니다."
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
