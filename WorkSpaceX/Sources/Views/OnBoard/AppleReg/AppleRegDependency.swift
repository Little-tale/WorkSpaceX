//
//  AppleRegDependency.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/9/24.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture
/*
 트러블 슈팅 Dependency 시 클래스 생명주기 이슈
 */

struct AppleRegDependency {
    var signIn: () async throws -> ASAuthorization
}

extension AppleRegDependency: DependencyKey {
    static var liveValue: AppleRegDependency {
        return Self(
            signIn: {
                try await withCheckedThrowingContinuation { continuation in
                    let request = ASAuthorizationAppleIDProvider().createRequest()
                    request.requestedScopes = [.fullName, .email]
                    let controller = ASAuthorizationController(authorizationRequests: [request])
                    let delegate = AppleSignInDelegate(continuation: continuation)
                    controller.delegate = delegate
                    controller.performRequests()
                    AppleSignInDelegateStore.shared.delegate = delegate
//                    DispatchQueue.main.async {
//                        continuation.resume(throwing: NSError(domain: "왜 안될까", code: -1))
//                    }
                }
            }
        )
    }
}

extension DependencyValues {
    var appleController: AppleRegDependency {
        get { self[AppleRegDependency.self] }
        set { self[AppleRegDependency.self] = newValue}
    }
}

final class AppleSignInDelegateStore {
    static let shared = AppleSignInDelegateStore()
    var delegate: AppleSignInDelegate?
}

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



/*
 extension AppleRegDependency: DependencyKey {
 static var liveValue: AppleRegDependency {
 let request = ASAuthorizationAppleIDProvider().createRequest()
 request.requestedScopes = [.fullName]
 
 return Self(
 appleSignInController: ASAuthorizationController(authorizationRequests: [request])
 )
 }
 }
 extension AppleRegDependency: DependencyKey {
 static var liveValue: AppleRegDependency = Self(
 appleSignInController: ASAuthorizationController(
 authorizationRequests: [
 ASAuthorizationAppleIDProvider().createRequest()
 ]
 )
 )
 }
 
 */
