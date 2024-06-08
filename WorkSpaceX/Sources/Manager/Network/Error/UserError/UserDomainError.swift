//
//  UserDomainError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum UserDomainError: DomainErrorType {
    case commonError(CommonError)
    case emailValid(APIErrorResponse)
    case kakaoLogin(APIErrorResponse)
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
        case .kakaoLogin(let errorModel):
            switch errorModel.errorCode {
            case "E03":
                return "로그인에 실패 하였습니다."
            case "E11":
                return "잘못된 요청입니다. 재시도 바랍니다."
            case "E12":
                return "이미 이메일로 회원 가입된 계정입니다."
            default :
                return "알수 없는 에러입니다."
            }
        case .commonError(let common):
            return common.message
        }
    }
    
    var errorCode: String {
        switch self {
        case .emailValid(let errorModel),
                .kakaoLogin(let errorModel) :
            return errorModel.errorCode
        case .commonError(let common):
            return common.errorCode
        }
    }
    
    var ifDevelopError: Bool {
        switch self {
        case .emailValid(let errorModel):
            switch errorModel.errorCode {
            case "E11":
                return true
            case "E12":
                return false
            default :
                return true
            }
        case .kakaoLogin(let errorModel):
            switch errorModel.errorCode {
            case "E03":
                return true
            case "E11":
                return true
            case "E12":
                return false
            default :
                return true
            }
        case .commonError(let common):
            return common.ifDevelopError
        }
    }
}
