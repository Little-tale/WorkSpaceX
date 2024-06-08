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
            let dto = mapper.requestLoginDTO(
                email: emailLogin.email,
                password: emailLogin.password,
                deviceToken: nil // 애플 처리후 적용
            )
            
            do {
                let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.emailLogin(dto))
                let mapping = mapper.toEntity(result)
                
                UserDefaultsManager.accessToken = result.token.accessToken
                UserDefaultsManager.accessToken = result.token.refreshToken
                
                return .success(mapping)
                
            } catch let error as APIError {
                let error = mapper.mappingEmailLoginError(error: error)
                return .failure(error)
                
            } catch {
                return .failure(.commonError(.fail))
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
