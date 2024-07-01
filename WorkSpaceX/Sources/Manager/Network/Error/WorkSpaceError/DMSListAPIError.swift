//
//  DMSListAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

struct DMSListAPIError: WSXErrorType {
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E13"
    ]
    
    var message: String {
        switch errorCode {
        case "E13":
            return "존재하지 않는 워크 스페이스 입니다."
        default:
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        !thisErrorCodes.contains { $0 == errorCode }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
