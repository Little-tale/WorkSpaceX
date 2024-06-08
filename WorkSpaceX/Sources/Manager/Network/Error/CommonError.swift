//
//  CommonError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum CommonError: String, DomainErrorType {
    case access = "E01"
    case unknownPath = "E97"
    case accessToken = "E05"
    case failAuthentication = "E02"
    case unknownAcount = "E03"
    case tooManyRequest = "E98"
    case serverError = "E99"
    case fail = "E100"
}
extension CommonError {
    
    var message: String {
        return switch self {
        case .access:
            "접근 권한이 없습니다."
        case .unknownPath:
            "알수 없는 경로"
        case .accessToken:
            "엑세스 토큰 만료"
        case .failAuthentication:
            "인증 실패"
        case .unknownAcount:
            "알수 없는 계정입니다."
        case .tooManyRequest:
            "너무 많은 호출이 감지되었습니다."
        case .serverError:
            "서버 에러가 발생 하였습니다."
        case .fail:
            "알수 없는 에러"
        }
    }
    
    var errorCode: String {
        return self.rawValue
    }
    
    var ifDevelopError: Bool {
        if case .unknownAcount = self {
            return false
        } else {
            return true
        }
    }
}
