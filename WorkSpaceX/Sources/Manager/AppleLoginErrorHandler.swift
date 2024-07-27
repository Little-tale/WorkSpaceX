//
//  AppleLoginErrorHandler.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/9/24.
//

import Foundation
import ComposableArchitecture

enum AppleLoginError: Error {
    case error
    case userCancel
   
    
    var message: String {
        switch self {
        case .error:
            "애플 로그인을 취소 하셨습니다."
        case .userCancel:
            "로그인에 문제가 발생하였습니다."
        }
    }
}

struct AppleLoginErrorHandler {
    var isUserError: (Error) -> AppleLoginError
}

extension AppleLoginErrorHandler: DependencyKey {
    static var liveValue: Self = Self(
        isUserError: { error in
            let error = error.localizedDescription
            if error.contains("1001") {
                return .userCancel
            }
            return .error
        }
    )
}

extension DependencyValues {
    var appleLoginErrorHandler: AppleLoginErrorHandler {
        get { self[AppleLoginErrorHandler.self] }
        set { self[AppleLoginErrorHandler.self] = newValue }
    }
}
