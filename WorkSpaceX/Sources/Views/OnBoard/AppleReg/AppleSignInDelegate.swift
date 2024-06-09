//
//  AppleLoginResult.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/9/24.
//

import Foundation
import AuthenticationServices

/// Apple Login 전용 딜리게이트 입니다.
final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    
    let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}
