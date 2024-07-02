//
//  DMSRoomAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation

struct DMSRoomAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11", "E13"
    ]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청입니다."
        case "E13":
            return "존재 하지 않는 워크스페이스 입니다."
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
