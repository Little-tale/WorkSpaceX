//
//  workSpaceMeError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation

struct WorkSpaceMeError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = ["E02"]
    
    var message: String {
        switch errorCode {
        case "E02":
            return "잘못된 요청입니다."
        default :
            return "알수없는 에러"
        }
    }
    
    var ifDevelopError: Bool {
        return true
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
