//
//  UserDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//
import Foundation
import ComposableArchitecture


struct UserDomainRepository {
    let mapper = UserRegMapper()
   
    var chaeckEmail: (String) async throws -> ()
}

extension UserDomainRepository: DependencyKey {
    

    static let liveValue: UserDomainRepository = Self(
        chaeckEmail: { email in
            let result = try await NetworkManger.shared.request(UserDomainRouter.userEmail(UserEmail(email: email)))
            return // 해당한게 Return 성공으로 간주
        }
    )
}

extension DependencyValues {
    var userDomainRepository: UserDomainRepository {
        get { self[UserDomainRepository.self] }
        set { self[UserDomainRepository.self] = newValue }
    }
}
