//
//  UserDomainError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum UserDomainError: DomainErrorType {
    case emailValid(APIErrorResponse)
}

extension UserDomainError {
    var message: String {
        switch self {
        case .emailValid(let errorModel):
            switch errorModel.errorCode {
            case "E11":
                return "잘못된 요청을 하고 있습니다."
            case "E12":
                return "중복된 이메일입니다. 입니다."
            default :
                return "응답 하나 알수없음"
            }
        }
    }
    
    var errorCode: String {
        switch self {
        case .emailValid(let errorModel):
            return errorModel.errorCode
        }
    }
}
