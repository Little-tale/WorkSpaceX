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
            case "E12":
                return "워크 스페이스 이름이 중복되었어요 ㅠㅠ"
            case "E21":
                return "X 크레딧이 부족해요!"
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
        case .meWorkSpaceError, .commonError:
            return true
        case .makeWoekSpaceError(let error):
            switch error {
            case "E11":
                return true
            case "E12":
                return false
            case "E21":
                return false
            default :
                return true
            
            }
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
            case "E11", "E12", "E21":
                return true
            default :
                return false
            }
        }
    }
    
}
