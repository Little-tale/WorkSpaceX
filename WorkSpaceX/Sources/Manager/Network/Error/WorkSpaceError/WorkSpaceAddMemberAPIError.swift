//
//  WorkSpaceAddMemberAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/20/24.
//

import Foundation

struct WorkSpaceAddMemberAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E03", "E11", "E12", "E13", "E14"
    ]
    
    var message: String {
        switch errorCode {
        case "E03":
            return "사용자를 찾을수가 없습니다!"
        case "E11":
            return "잘못된 이메일 형식입니다."
        case "E12":
            return "이미 해당유저는 워크스페이스 멤버에요!"
        case "E13":
            return "현재 워크스페이스를 찾을 수 없어요!"
        case "E14":
            return "워크스페이스 관리자만 멤버를 초대할 수 있습니다."
        default :
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        switch errorCode {
        case "E03":
            return false
        case "E11":
            return false
        case "E12":
            return false
        case "E13":
            return false
        case "E14":
            return false
        default :
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }

}
