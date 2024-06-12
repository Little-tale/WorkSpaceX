//
//  AppleLoginError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation

struct AppleLoginAPIError: WSXErrorType {
    
    var errorCode: String
    
    private(set) var thisErrorCodes = [
        "E03", "E11", "E12"
    ]
    
    var message: String {
        switch errorCode {
        case "E03":
            return "로그인 실패 하였습니다."
        case "E11":
            return "잘못된 유저입니다."
        case "E12":
            return "이미 이메일로 가입된 유저입니다."
        default :
            return "알수없는 에러"
        }
    }
    
    var ifDevelopError: Bool {
        return errorCode == "E03" || errorCode == "E11"
    }

    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }

}
