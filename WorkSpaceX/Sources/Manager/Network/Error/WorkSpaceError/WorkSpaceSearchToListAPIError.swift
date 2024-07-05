//
//  WorkSpaceSearchToListAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation

struct WorkSpaceSearchToListAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E13", "E11"
    ]
    
    var message: String {
        switch errorCode {
        case "E13":
            return "" // 없는 데이터 무시
        case "E11":
            return "빈값을 요청하지 마십시오"
        default :
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E13":
            return true
        case "E11":
            return false
        default :
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
