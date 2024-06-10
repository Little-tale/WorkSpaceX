//
//  UserDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//
import Foundation
import ComposableArchitecture


struct UserDomainRepository {

    var chaeckEmail: (String) async -> Result<Void, APIError>
    var requestUserReg: (UserRegEntityModel)  async -> Result<UserEntity, APIError>
    var requestKakaoUser: ((oauthToken: String,
                           deviceToken: String)
    ) async -> (Result<UserEntity, UserDomainError>)
    
    var requestEmailLogin: ((email: String, password: String)) async -> Result<UserEntity, UserDomainError>
    
    var appleLoginRequest: () async throws -> UserEntity

}

extension UserDomainRepository: DependencyKey {
    
    static let mapper = UserRegMapper()
    
    static let liveValue: UserDomainRepository = Self(
        chaeckEmail: { email in
            do {
                let _ = try await NetworkManager.shared.request(UserDomainRouter.userEmail(UserEmail(email: email)))
                return .success(())
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknownError)
            }
        }, requestUserReg: { userModel in
            do {
                let dto = mapper.userRegDTO(user: userModel)
                let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.userReg(dto))
                let reEntry = mapper.toEntity(result)
                UserDefaultsManager.accessToken = result.token.accessToken
                UserDefaultsManager.accessToken = result.token.refreshToken
                UserDefaultsManager.userName = result.nickname
                print("accessToken",UserDefaultsManager.accessToken)
                print("refreshToken",UserDefaultsManager.refreshToken)
                return .success(reEntry)
            } catch let error as APIError {
                return .failure(error)
            } catch {
                return .failure(.unknownError)
            }
        }, requestKakaoUser: { kakao in
            do {
                let dtoRequest = mapper.kakaoUser(
                    oauthToken: kakao.oauthToken,
                    deviceToken: kakao.deviceToken
                )
                let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.kakaoLogin(dtoRequest))
                let entity = mapper.toEntity(result)
                
                UserDefaultsManager.accessToken = result.token.accessToken
                UserDefaultsManager.accessToken = result.token.refreshToken
                UserDefaultsManager.userName = result.nickname
                
                print("accessToken",UserDefaultsManager.accessToken)
                print("refreshToken",UserDefaultsManager.refreshToken)
                return .success(entity)
            } catch let error as APIError {
                let mapping = mapper.mapAPIErrorTOKakaoUserDomainError(error)
                return .failure(mapping)
            } catch {
                return .failure(.commonError(.fail))
            }
        }, requestEmailLogin: { emailLogin in
            var tokken: String?
            if UserDefaultsManager.deviceToken != "" {
                tokken = UserDefaultsManager.deviceToken
            }
            let dto = mapper.requestLoginDTO(
                email: emailLogin.email,
                password: emailLogin.password,
                deviceToken: tokken
            )
            
            do {
                let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.emailLogin(dto))
                let mapping = mapper.toEntity(result)
                
                
                UserDefaultsManager.accessToken = result.token.accessToken
                UserDefaultsManager.accessToken = result.token.refreshToken
                UserDefaultsManager.userName = result.nickname
                
                return .success(mapping)
                
            } catch let error as APIError {
                let error = mapper.mappingEmailLoginError(error: error)
                return .failure(error)
                
            } catch {
                return .failure(.commonError(.fail))
            }
        }, appleLoginRequest: {
            do {
                let success = try await DependencyValues.live.appleController.signIn()
                let user = mapper.mappingASAuthorization(info: success)
                
                guard let user else {
                    throw AppleLoginError.error
                }
                
                let result = try await NetworkManager.shared.requestDto(
                    UserDTO.self,
                    router: UserDomainRouter.appleLoginRegister(user)
                )
                
                UserDefaultsManager.userName = result.nickname
                UserDefaultsManager.refreshToken = result.token.refreshToken
                UserDefaultsManager.accessToken = result.token.accessToken
                
                let entity = mapper.toEntity(result)
                
                return entity
            } catch (let error as APIError) {
                let result = mapper.mappingAppleLoginToUserDomainError(apE: error)
                throw result
            } catch {
                // 사용자 취소도 에러로 받아짐.
                throw DependencyValues.live.appleLoginErrorHandeler.isUserError(error)
            }
            
        }
    )
}

extension DependencyValues {
    var userDomainRepository: UserDomainRepository {
        get { self[UserDomainRepository.self] }
        set { self[UserDomainRepository.self] = newValue }
    }
}
