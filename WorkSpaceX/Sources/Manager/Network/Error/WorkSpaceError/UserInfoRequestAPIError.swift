//
//  UserInfoRequestAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation

struct UserInfoRequestAPIError: WSXErrorType {
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E03"]
    
    var message: String {
        switch errorCode {
        case "E03":
            return "알수 없는 계정입니다."
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
