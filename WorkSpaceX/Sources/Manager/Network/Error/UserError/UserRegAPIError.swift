//
//  UserRegAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation


struct UserRegAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E11", "E12"]
    
    var message: String {
        switch errorCode {
        case "E11":

            return "잘못된 요청입니다."
            
        case "E12":
            
            return "중복된 이메일 입니다."
        default:
            return "알수없는 에러"
        }
    }
    
   
    
    var ifDevelopError: Bool {
        return false
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
