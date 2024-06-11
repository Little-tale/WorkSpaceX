//
//  AuthError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

enum AuthError: DomainErrorType{
    static let refreshDeadCode = "E06"
    case refreshDead(APIErrorResponse)
}
extension AuthError {
    
    var message: String {
        switch self {
        case let .refreshDead(error):
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
        case let .refreshDead(error):
            return error.errorCode
        }
    }
    
    var ifDevelopError: Bool {
        switch self {
        case let .refreshDead(errorModel):
            switch errorModel.errorCode {
            case "E06":
                return false
            default :
                return true
            }
        }
    }
}
