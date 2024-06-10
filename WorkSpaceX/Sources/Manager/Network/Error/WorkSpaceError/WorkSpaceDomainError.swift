//
//  WorkSpaceAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation

enum WorkSpaceDomainError: DomainErrorType {
    case commonError(CommonError)
    case meWorkSpaceError(String)
    case makeWoekSpaceError(String)
}

extension WorkSpaceDomainError {
    var message: String {
        switch self {
        case .commonError(let common):
            return common.message
        case .meWorkSpaceError(let errorCode):
            switch errorCode {
            case "E02":
                return "잘못된 요청입니다."
            default :
                return "알수없는 에러"
            }
        
        case .makeWoekSpaceError(let errorCode):
            switch errorCode {
            case "E11":
                return "잘못된 요청입니다."
            default :
                return "알수없는 에러"
            }
        }
    }
    
    var errorCode: String {
        switch self {
        case .commonError(let common):
            return common.errorCode
        case let .meWorkSpaceError(errorCode):
            return errorCode
        case let .makeWoekSpaceError(errorCode):
            return errorCode
        }
    }
    
    var ifDevelopError: Bool {
        switch self {
        case .meWorkSpaceError, .makeWoekSpaceError, .commonError:
            return true
        }
        
    }
    /// 공통에러와 분리를 원한다면
    var thisError: Bool {
        switch self {
        case .commonError:
            return false
        case let .meWorkSpaceError(errorCode):
            switch errorCode {
            case "E02":
                return true
            default :
                return false
            }
        case let .makeWoekSpaceError(errorCode):
            switch errorCode {
            case "E11":
                return true
            default :
                return false
            }
        }
    }
    
}
