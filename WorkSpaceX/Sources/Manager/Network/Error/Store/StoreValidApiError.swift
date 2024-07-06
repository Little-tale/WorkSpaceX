//
//  storeValidApiError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation

struct StoreValidApiError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E11", "E81", "E82"]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청입니다."
        case "E81":
            return "존재하지 않는 결제건 입니다."
        case "E82":
            return "유효하지 않는 결제건 입니다."
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
