//
//  AuthError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

struct reFreshError: WSXErrorType {
    
    var errorCode: String 
    
    var thisErrorCodes: [String] = ["E06"]
    
}
extension reFreshError {
    
    var message: String {
        
        switch errorCode {
        case "E06":
            return "재로그인이 필요합니다."
        default :
            return "알수 없는 에러"
        }

    }

    var ifDevelopError: Bool {
        return false
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
