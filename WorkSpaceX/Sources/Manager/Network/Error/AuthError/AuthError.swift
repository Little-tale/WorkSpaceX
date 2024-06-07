//
//  AuthError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

enum AuthError: DomainErrorType{
    case emailValid(APIErrorResponse)
}
extension AuthError {
    
    var message: String {
        switch self {
        case .emailValid(let error):
            switch error.errorCode {
            case "E06":
                return "재로그인이 필요합니다."
            default :
                return "알수 없는 에러"
            }
        }
    }
    
    var errorCode: String {
        switch self {
        case .emailValid(let error):
            return error.errorCode
        }
    }
}
