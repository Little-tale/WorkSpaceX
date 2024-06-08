//
//  DomainErrorType.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation


/// 개발자 잘못일 경우 메시지나 에러코드를 통해 핸들링 바랍니다.
/// 만약 클라이언트 잘못일경우
protocol DomainErrorType: Error, Equatable {
    
    var message: String { get }
    
    var errorCode: String { get }
    
    /// 계발자 잘못인지 알려줍니다.
    var ifDevelopError: Bool { get }
}
