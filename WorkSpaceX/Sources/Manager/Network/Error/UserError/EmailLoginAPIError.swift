//
//  EmailLoginAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation


struct EmailLoginAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E03"]
    
    var message: String {
        switch errorCode {
        case "E03":
            return "이메일이나, 비밀번호를 다시 확인하여 주세요"
        default :
            return "알수 없는 에러입니다."
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E03":
            return false
        default :
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
