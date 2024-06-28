//
//  ChannelEditAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/28/24.
//

import Foundation

struct ChannelEditAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = [
        "E11","E12","E13","E14",
    ]
    
    var message: String {
        switch errorCode {
        case "E11":
            return "잘못된 요청입니다."
        case "E12":
            return "변경 사항이 없어요!"
        case "E13":
            return "존재하지 않는 워크 채널 혹은 워크스페이스 에요!"
        case "E14":
            return "채널 관리자만 채널을 수정할 수 있습니다."
        default:
            return ""
        }
    }
    
    var ifDevelopError: Bool {
        if thisErrorCodes.contains(where: { $0 == errorCode }) {
            return false
        } else {
            return true
        }
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return ChannelEditAPIError(errorCode: customError)
    }
    
    
}
