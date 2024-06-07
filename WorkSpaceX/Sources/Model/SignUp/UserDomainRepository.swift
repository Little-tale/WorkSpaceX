//
//  UserDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//
import Foundation
import ComposableArchitecture


struct UserDomainRepository {
    
    
    var chaeckEmail: (String) async throws -> ()
    var requestUserReg: (UserRegEntityModel)  async throws -> (UserEntity)
}

extension UserDomainRepository: DependencyKey {
    
    static let mapper = UserRegMapper()
    
    static let liveValue: UserDomainRepository = Self(
        chaeckEmail: { email in
            let result = try await NetworkManger.shared.request(UserDomainRouter.userEmail(UserEmail(email: email)))
            return // 해당한게 Return 성공으로 간주
        }, requestUserReg: { userModel in
            let dto = mapper.userRegDTO(user: userModel)
            let result = try await NetworkManger.shared.requestDto(UserDTO.self, router: UserDomainRouter.userReg(dto))
            let reEntry = mapper.toEntity(result)
            return reEntry
        }
    )
}

extension DependencyValues {
    var userDomainRepository: UserDomainRepository {
        get { self[UserDomainRepository.self] }
        set { self[UserDomainRepository.self] = newValue }
    }
}