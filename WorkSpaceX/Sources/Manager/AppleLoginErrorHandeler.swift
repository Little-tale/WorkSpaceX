//
//  AppleLoginErrorHandeler.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/9/24.
//

import Foundation
import ComposableArchitecture

struct AppleLoginErrorHandeler {
        
    var isUserError: (Error) -> String
    
}

extension AppleLoginErrorHandeler: DependencyKey {
    static var liveValue: Self = Self(
        isUserError: { error in
            let error = error.localizedDescription
            
            if error.contains("1001") {
                return "애플 로그인을 취소 하셨습니다."
            }
            return "로그인에 문제가 발생하였습니다."
        }
    )
}

extension DependencyValues {
    var appleLoginErrorHandeler: AppleLoginErrorHandeler {
        get { self[AppleLoginErrorHandeler.self] }
        set { self[AppleLoginErrorHandeler.self] = newValue }
    }
}
