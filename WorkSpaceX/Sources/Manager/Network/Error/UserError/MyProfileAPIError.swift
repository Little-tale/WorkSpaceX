//
//  MyProfileAPIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation

/// 해당 에러에선 에러코드가 전부 공통에러에 해당합니다. 공통에러를 이용하세요!
struct MyProfileAPIError: WSXErrorType {
    
    var errorCode: String
    
    var thisErrorCodes: [String] = []
    
    var message: String {
        return ""
    }
    
    var ifDevelopError: Bool {
        return false
    }
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
