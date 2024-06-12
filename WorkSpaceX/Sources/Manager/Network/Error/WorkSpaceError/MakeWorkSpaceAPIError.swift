//
//  makeWorkSpaceAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation

struct MakeWorkSpaceAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11", "E12", "E21"
    ]
    
    var message: String {
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
    
    var ifDevelopError: Bool {
        switch errorCode {
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
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
