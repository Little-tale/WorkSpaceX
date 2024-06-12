//
//  KakaoLoginAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation

struct KakaoLoginAPIError: WSXErrorType {
    
    var errorCode: String
    
    private(set) var thisErrorCodes = [
        "E03", "E11", "E12"
    ]
    
    var message: String {
        switch errorCode {
        case "E03":
            return "로그인에 실패하였습니다. 재시도 바랍니다."
        case "E11":
            return "잘못된 요청입니다. 재시도 바랍니다."
        case "E12":
            return "이미 이메일로 회원 가입된 계정입니다."
        default:
            return "알 수 없는 에러입니다."
        }
    }
    
    var ifDevelopError: Bool {
        return errorCode == "E03" || errorCode == "E11"
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
