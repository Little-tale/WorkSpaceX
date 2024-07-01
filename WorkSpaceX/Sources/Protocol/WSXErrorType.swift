//
//  DomainErrorType.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation


/// 개발자 잘못일 경우 메시지나 에러코드를 통해 핸들링 바랍니다.
/// 만약 클라이언트 잘못일경우
protocol WSXErrorType: Error, Equatable {
    
    var errorCode: String { get }
    
    var thisErrorCodes: [String] { get }
    
    var message: String { get }
    
    /// 계발자 잘못인지 알려줍니다.
    var ifDevelopError: Bool { get }
    
    var ifThisError: Bool { get }
    
    var ifCommonError: CommonError? { get }
    
    static func makeErrorType(from customError: String) -> Self
}


extension WSXErrorType {
    
    var ifCommonError: CommonError? {
        return CommonError(rawValue: errorCode)
    }
    
    var ifThisError: Bool {
        return !thisErrorCodes.contains(errorCode)
    }
    
    var ifReFreshDead: Bool {
        let refresh = reFreshError(errorCode: errorCode)
        return refresh.ifThisError
    }
}
