//
//  UserDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//
import Foundation
import ComposableArchitecture


struct UserDomainRepository {
    
    var chaeckEmail: (String) async throws -> Void
    var requestUserReg: (UserRegEntityModel) async throws -> UserEntity
    var requestKakaoUser: ((oauthToken: String,
                            deviceToken: String)
    ) async throws -> UserEntity
    
    var requestEmailLogin: ((email: String, password: String)) async throws -> UserEntity
    
    var appleLoginRequest: () async throws -> UserEntity
    
    var myProfile: () async throws -> UserInfoEntity
    
    var profileInfoEdit: (_ nickname: String,_ contact: String) async throws -> UserEntity
    
    var profileImageEdit: (_ data: Data) async throws -> UserEntity
    
    var otherUserProfileRequest: (_ userID: String) async throws -> WorkSpaceMemberEntity
}

extension UserDomainRepository: DependencyKey {
    
    static let mapper = UserRegMapper()
    
    
    static let liveValue: UserDomainRepository = Self(
        chaeckEmail: { email in
            
            let model = try await NetworkManager.shared.request(UserDomainRouter.userEmail(UserEmail(email: email)), errorType: EmailValidError.self)
            
            return
            
        }, requestUserReg: { userModel in
            
            let dto = mapper.userRegDTO(user: userModel)
            let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.userReg(dto), errorType: UserRegAPIError.self)
            
            
            
            let reEntry = mapper.toEntity(result)
            UserDefaultsManager.accessToken = result.token.accessToken
            UserDefaultsManager.accessToken = result.token.refreshToken
            
            UserDefaultsManager.userName = result.nickname
            
            UserDefaultsManager.userID = result.userID
            
            print("accessToken",UserDefaultsManager.accessToken ?? "nil")
            print("refreshToken",UserDefaultsManager.refreshToken ?? "nil")
            
            return reEntry
            
        }, requestKakaoUser: { kakao in
            
            let dtoRequest = mapper.kakaoUser(
                oauthToken: kakao.oauthToken,
                deviceToken: kakao.deviceToken
            )
            let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.kakaoLogin(dtoRequest), errorType: KakaoLoginAPIError.self)
            
            
            
            let entity = mapper.toEntity(result)
            
            UserDefaultsManager.accessToken = result.token.accessToken
            UserDefaultsManager.accessToken = result.token.refreshToken
            
            UserDefaultsManager.userName = result.nickname
            UserDefaultsManager.userID = result.userID
            
            print("accessToken",UserDefaultsManager.accessToken ?? "nil")
            print("refreshToken",UserDefaultsManager.refreshToken ?? "nil")
        
            return entity
            
        }, requestEmailLogin: { emailLogin in
            var token: String?
            if UserDefaultsManager.deviceToken != "" {
                token = UserDefaultsManager.deviceToken
            }
            let dto = mapper.requestLoginDTO(
                email: emailLogin.email,
                password: emailLogin.password,
                deviceToken: token
            )
            
            
            let result = try await NetworkManager.shared.requestDto(UserDTO.self, router: UserDomainRouter.emailLogin(dto), errorType: EmailLoginAPIError.self)
            
            let mapping = mapper.toEntity(result)
            
            UserDefaultsManager.accessToken = result.token.accessToken
            UserDefaultsManager.accessToken = result.token.refreshToken
            
            UserDefaultsManager.userName = result.nickname
            UserDefaultsManager.userID = result.userID
            print("이메일 로그인시 토큰 \(result.token)")
            
            print("이메일 유저디폴트 입장 \(UserDefaultsManager.accessToken ?? "nil")")
            
            UserDefaultsManager.ifEmailLogin = true
            
            return mapping
            
        }, appleLoginRequest: {
            
            let success = try await DependencyValues.live.appleController.signIn()
            let user = mapper.mappingASAuthorization(info: success)
            
            guard let user else {
                throw AppleLoginError.error
            }
            
            let result = try await NetworkManager.shared.requestDto(
                UserDTO.self,
                router: UserDomainRouter.appleLoginRegister(user),
                errorType: AppleLoginAPIError.self
            )
            
            dump(result)
            UserDefaultsManager.userName = result.nickname
            UserDefaultsManager.userID = result.userID
            UserDefaultsManager.refreshToken = result.token.refreshToken
            
            UserDefaultsManager.accessToken = result.token.accessToken
            
            let entity = mapper.toEntity(result)
            
            return entity
        }, myProfile: {
            print("프로필 조회 시작")
            let profileDTO = try await NetworkManager.shared.requestDto(UserProfileDTO.self, router: UserDomainRouter.myProfile, errorType: MyProfileAPIError.self)
            
            let mapping = mapper.toEntityProfile(profileDTO)
            
            return mapping
        }, profileInfoEdit: { nickname, contact in
            
            let requestModel = UserInfoEditRequestDTO(
                nickname: nickname,
                phone: contact
            )
            let result = try await NetworkManager.shared
                .requestDto(UserEditDTO.self, router: UserDomainRouter.editUserInfo(requestModel), errorType: UserEditAPIError.self)
            let mapping = mapper.toEntity(result)
            
            return mapping
        }, profileImageEdit: { data in
            let result = try await NetworkManager.shared.requestDto(UserEditDTO.self, router: UserDomainRouter.editUserProfileImage(
                image: data,
                boundary: MultipartFormData.randomBoundary()
            ), errorType: UserEditAPIError.self)
            let mapping = mapper.toEntity(result)
            return mapping
        }, otherUserProfileRequest: { otherUser in
            
            let result = try await NetworkManager.shared.requestDto(
                WorkSpaceAddMemberDTO.self,
                router: WorkSpaceRouter.requestUser(userID: otherUser),
                errorType: WorkSpaceMembersAPIError.self
            )
            
            let mapping = mapper.toEntity(result)
            return mapping
        }
    )
}

extension DependencyValues {
    var userDomainRepository: UserDomainRepository {
        get { self[UserDomainRepository.self] }
        set { self[UserDomainRepository.self] = newValue }
    }
}
