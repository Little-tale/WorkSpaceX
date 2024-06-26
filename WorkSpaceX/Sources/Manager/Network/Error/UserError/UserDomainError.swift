////
////  UserDomainError.swift
////  WorkSpaceX
////
////  Created by Jae hyung Kim on 6/6/24.
////
//
//import Foundation
//
//enum UserDomainError: WSXErrorType {
//    case commonError(CommonError)
//    case emailValid(String)
//    case kakaoLogin(String)
//    case emailLoginError(String)
//    case appleLoginError(String)
//}
//
//extension UserDomainError {
//    var message: String {
//        switch self {
//        case .emailValid(let errorModel):
//            switch errorModel {
//            case "E11":
//                return "잘못된 요청을 하고 있습니다."
//            case "E12":
//                return "중복된 이메일입니다. 입니다."
//            default :
//                return "응답 하나 알수없음"
//            }
//        case .kakaoLogin(let errorModel):
//            switch errorModel {
//            case "E03":
//                return "로그인에 실패 하였습니다."
//            case "E11":
//                return "잘못된 요청입니다. 재시도 바랍니다."
//            case "E12":
//                return "이미 이메일로 회원 가입된 계정입니다."
//            default :
//                return "알수 없는 에러입니다."
//            }
//        case .emailLoginError(let errorModel):
//            switch errorModel {
//            case "E03":
//                return "로그인에 실패 하였습니다."
//            default :
//                return "알수 없는 에러입니다."
//            }
//        case .commonError(let common):
//            return common.message
//            
//        case .appleLoginError(let errorModel):
//            switch errorModel {
//            case "E03":
//                return "로그인 실패 하였습니다."
//            case "E11":
//                return "잘못된 유저입니다."
//            case "E12":
//                return "이미 이메일로 가입된 유저입니다."
//            default :
//                return "알수없는 에러"
//            }
//        }
//    }
//    
//    var errorCode: String {
//        switch self {
//        case .emailValid(let errorModel),
//                .kakaoLogin(let errorModel) :
//            return errorModel
//            
//        case .commonError(let common):
//            return common.errorCode
//            
//        case .emailLoginError(let emailLogin):
//            return emailLogin
//            
//        case .appleLoginError(let error):
//            return error
//        }
//    }
//    
//    var ifDevelopError: Bool {
//        switch self {
//        case .emailValid(let errorModel):
//            switch errorModel {
//            case "E11":
//                return true
//            case "E12":
//                return false
//            default :
//                return true
//            }
//        case .kakaoLogin(let errorModel):
//            switch errorModel {
//            case "E03":
//                return true
//            case "E11":
//                return true
//            case "E12":
//                return false
//            default :
//                return true
//            }
//        case .emailLoginError(let errorModel):
//            switch errorModel {
//            case "E03":
//                return false
//            default :
//                return true
//            }
//        case .appleLoginError(let errorModel):
//            switch errorModel {
//            case "E03":
//                return true
//            case "E11":
//                return true
//            case "E12":
//                return false
//            default:
//                return true
//            }
//            
//        case .commonError(let common):
//            return common.ifDevelopError
//        }
//    }
//    
//    var ifThisError: Bool {
//        switch self {
//        case .commonError:
//            return false
//        case .emailValid(let error):
//            switch error {
//            case "E11":
//                return true
//            case "E12":
//                return true
//            default :
//                return true
//            }
//        case .kakaoLogin(let error):
//            switch error {
//            case "E03":
//                return true
//            case "E11":
//                return true
//            case "E12":
//                return true
//            default :
//                return false
//            }
//            
//        case .appleLoginError:
//           return true
//            
//        case .emailLoginError(let error):
//            switch error {
//            case "E03":
//                return true
//            default :
//                return true
//            }
//        }
//    }
//}
//
