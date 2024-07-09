<img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/f5f1e1d6-2137-4486-965a-ee930c2fea60" width="100" height="100"/>


# WorkSpaceX

- WorkSpaceX는 팀플, 회사, 업무용 SNS 앱 입니다.


# 📷 소개 사진
<picture>
    <img src ="https://github.com/Little-tale/WorkSpaceX/assets/116441522/2e8a205a-541f-4b8a-9a26-60a857c14243">
</picture>

# 📷 프로젝트 소개
 
- WorkSpaceX는 이미지와 파일, 글을 전송하고 공유할 수 있습니다.
- 실시간 채팅 기능을 지원합니다.
- 코인을 결제하여, 워크스페이스를 생성할 수 있습니다.
- 검색 기능을 지원하여, 다른 사용자나 채널 등을 검색 할 수 있습니다.
- 관리자일 경우엔 워크 스페이스 혹은 채널 등을 수정하거나 멤버를 초대 할 수 있습니다.

## 📸 개발 기간

> 6/4 ~ 7/9 (대략 한달)
> 

## 📸 앱 개발 환경
- 최소 지원 버전: iOS 16.0+
- Xcode Version 15.4.0

## 📷 사용한 기술

- SwiftUI 
-  TCA(ComposableArchitecture) / TCACoordinators
-   URLSession / iamport / SocketIO / Codable
-   Realm / UserDefaults
-   PopupView / Kingfisher 

## 📷 기술설명

### TCA + SwiftUI

> 단방향 아키텍처인 TCA(ComposableArchitecture)를 적용하여 상태관리의 일관성을 유지하고, 
재사용 가능한 컴포턴트들로 분리하여 유지보수성을 높였습니다.
> 

```swift
import ComposableArchitecture

struct UserDomainRepository {
    
    var chaeckEmail: (String) async throws -> Void

    var requestUserReg: (UserRegEntityModel) async throws -> UserEntity

    var requestKakaoUser: ((oauthToken: String, deviceToken: String)) async throws -> UserEntity

    var profileImageEdit: (_ data: Data) async throws -> UserEntity
    
    var otherUserProfileReqeust: (_ userID: String) async throws -> WorkSpaceMemberEntity
    
    ........
}

 ///// Other Feature

@Reducer
struct ProfileInfoFeature {

    @ObservableState
    struct State: Equatable {
         ....
    }
 
    enum Action {
        case onAppaer
        case delegate(Delegate)
        case parentAction(ParentAction)
        .....
        
        enum Delegate { // 부모에게 전달
            .... 
        }
       
        enum ParentAction { // 부모에게 전달받음
            ...
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workRepo
    
    @Dependency(\.userDomainRepository) var userRepo
    
    @Dependency(\.realmRepository) var realmRepo
    
    @Dependency(\.notificationStateManager) var notiManager
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
           ....
            default:
                break
            }
            return .none
        }
    }
}
```

## URLSession + RouterPattern + Custom intercept + Custom Retry

> URLSession을 통해 도메인별 Router를 분리하여 구조화 하였습니다.
> 직접 Intercept와 Retry를 구현하여 accessToken이 만료 되었을 시 RefreshToken을 통해
> 재생성할 수 있도록 하였습니다.


```swift
import Foundation

protocol NetworkManagerType {
    func request<T: Router, E: WSXErrorType>(_ router: T, errorType: E.Type) async throws -> Data
    func requestDto<T: DTO, R: Router, E: WSXErrorType>(_ model: T.Type, router: R, errorType: E.Type) async throws -> T
}

struct NetworkManager: NetworkManagerType {
    static let shared = NetworkManager()
}

extension NetworkManager {
    ......

    private func startIntercept<E: WSXErrorType>(_ urlRequest: inout URLRequest, retryCount: Int, errorType: E.Type) async throws -> Data {
  
           let request = intercept(&urlRequest)
           do {
               let data = try await performRequest(request, errorType: errorType)
               return data
           } catch let error as E where retryCount > 0 {
               if error.ifCommonError?.isAccessTokenError == true {
                   try await RefreshTokenManager.shared.refreshAccessToken()
                   
                   return try await startIntercept(&urlRequest, retryCount: retryCount - 1, errorType: errorType)
               } else {
                   throw error
               }
           } catch {
               throw error
           }
       }
    
    private func intercept(_ request: inout URLRequest) -> URLRequest {
        if let access = UserDefaultsManager.accessToken {
            request.setValue(access, forHTTPHeaderField: WSXHeader.Key.authorization)
        }
        return request
    }
}
```

## MultipartFormData
> 
직접 `MultipartFormData` 로직을 구현하여, 이미지, PDF, Zip 파일을 전송하여 공유 할 수 있도록 하였습니다.
> 
```swift
protocol MultipartFormDataType {
  
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String, boundary: String)
    
    func finalize(boundary: String) -> Data
    
    func headers(boundary: String) -> HTTPHeaders
}

// 파일 타입
enum FileType: String {
    case image
    case pdf = "pdf"
    case zip = "zip"
    case unknown
    
    var mimeType: String {
        switch self {
        case .image:
            return "image/jpeg"
        case .pdf:
            return "application/pdf"
        case .zip:
            return "application/zip"
        case .unknown:
            return "application/octet-stream"
        }
    }
}

final class MultipartFormData: MultipartFormDataType {
    
    private var body = Data()
    
    static func randomBoundary() -> String {
        let first = UInt32.random(in: UInt32.min...UInt32.max)
        let second = UInt32.random(in: UInt32.min...UInt32.max)
        
        return String(format: "workSpaceX.boundary.%08x%08x", first, second)
    }
    
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String, boundary: String) {
        // 멀티파트의 시작을 알리는 boundary 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        ...  
    }
    
    /// 모든 파트를 추가한 경우 최종적으로 명시
    func finalize(boundary: String) -> Data {
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    func headers(boundary: String) -> HTTPHeaders {
        return [WSXHeader.Key.contentType: "\(WSXHeader.Value.multipartFormData); boundary=\(boundary)"]
    }
}
```

## AsyncStream + @Sendable
AsyncStream와 @Sendable을 사용하여 비동기 함수가 스레드에 안전하게 호출될 수 있도록 하였습니다.
호출자가 사라지면 함수가 알아서 종료되도록 하였습니다.

```swift
@MainActor
    func observeNewMessage(dmRoomID: String) -> AsyncStream<[DMChatRealmModel]> {
        return AsyncStream { continuation in
            Task { @MainActor in
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    
                    guard let dmRoom = realm.object(ofType: DMSRoomRealmModel.self, forPrimaryKey: dmRoomID) else {
                        continuation.finish()
                        return
                    }
                    
                    let token = dmRoom.chatMessages.observe { change in
                        Task { @MainActor in
                            switch change {
                            case .initial:
                                break
                            case .update(let models, deletions: _, insertions: let insertAt, modifications: _):
                                
                                let new = insertAt.map { models[$0] }
        
                                continuation.yield(Array(new))
                            case .error(_):
                                continuation.finish()
                            }
                        }
                    }
                    
                    tokens[dmRoomID] = token
                    
                    continuation.onTermination = { @Sendable [weak self] _ in
                        token.invalidate()
                        self?.tokens[dmRoomID] = nil
                    }
                } catch {
                    continuation.finish()
                }
            }
        }
    }

```

## subscript + Collection
> Collection의 확장을 통해 인덱스 접근의 안전성을 보장하였습니다.
```swift
extension Collection {
    /// 인덱스 터짐 방지
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
```



## CustomAlertView + WindowLevel
> 사이드 메뉴 에서도 커스텀 된 Alert 을 표현하기위해, `UIWindow` 레벨을 통해 알림 창을 구현하였습니다. 
```swift
final class CustomAlertWindow {
    static let shared = CustomAlertWindow()
    private var window: UIWindow?
    
    func show<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        if let windowSceen = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowSceen)
            
            let hostingController = UIHostingController(rootView: content())
            
            hostingController.view.backgroundColor = .clear
            
            window.rootViewController = hostingController
            window.windowLevel = .alert + 1
            window.makeKeyAndVisible()
            self.window = window
            
            hostingController.view.alpha = 0
            UIView.animate(withDuration: 0.3) {
                hostingController.view.alpha = 1
            }
        }
    }
    
    func hide() {
        self.window?.isHidden = true
    
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            window?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else {
                self?.window = nil
                return
            }
            window = nil
        }
    }
}
```
## TCACoordinators
> `TCACoordinator`를 활용하여  각 Feature 와 복잡한 네비게이션 구조를 관리하고 구조화 하였습니다.

```swift
import TCACoordinators

@Reducer(state: .equatable)
enum DMSListScreens {
    case dmHome(DMSListFeature)
    case dmChat(DMSChatFeature)
    case profileInfo(ProfileInfoFeature)
    case profileEdit(ProfileInfoEditFeature)
    // sheet
    case memberAdd(AddMemberFeature)
    
    // 결제
    case storeListView(StoreListFeature)
}

@Reducer
struct DMSCoordinator { ... }

/// View 
struct DMSCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<DMSCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.identeRoutes, action: \.router)) { screen in
                switch screen.case {
                case let .dmHome(store):
                    DMSListView(store: store)
                case let .memberAdd(store):
                    AddMemberView(store: store)
                case let .dmChat(store):
                    DMSChatView(store: store)
                case let .profileInfo(store):
                    ProfileInfoView(store: store)
                case let .profileEdit(store):
                    ProfileInfoEditView(store: store)
                case let .storeListView(store):
                    StoreListView(store: store)
                }
            }
        }
    }
}

```



# UI

| 로그인 화면 | 회원 가입 (비밀번호 가려짐) | 초기(워크스페이스 없을시) | 워크 스페이스 홈화면 |
|:---:|:---:|:---:|:---:| 
|<picture><img src="https://github.com/kickbell/SwiftUiFirebaseChat/assets/116441522/d281920a-f7d6-4a18-b57f-295c89ac24ce" width="200" height="440"/></picture>| <picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/bf856aa5-7ff1-49ac-b063-1097abb182b4" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/7fea8b7f-4024-4dcd-8c6a-1392d44a8f7d" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/776d499b-87d3-4347-88c1-cac615f7096b" width="200" height="400"/>

| 워크 스페이스 전환시 | 워크스페이스 멤버 초대 | 워크스페이스 삭제 | 권한 양도 및 나가기 |
|:---:|:---:|:---:|:---:|
|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/e56e468d-ba5d-4a84-99f4-cf2517cb6c0f" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/7f130a53-1105-4f03-870a-51f96a543ca4" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/d516b392-40ef-4c1b-babc-7fe41fe94555" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/8f2fa641-da3e-49c6-9903-4e04fbe7e49d" width="200" height="440"/></picture>|

| DM 리스트 | 채팅 | 사진 또는 파일 전송 | 사진 또는 파일 클릭시 |
|:---:|:---:|:---:|:---:|
|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/473c8c7d-77bc-4b46-85e5-66ef1d733606" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/81d1584b-e438-4d58-b5f4-37999a71f71c" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/e075935f-645c-461a-bf4d-aea9a39d0965" width="200" height="440"/></picture><picture>|<img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/13d05646-6939-407d-9960-81af364f9c11" width="200" height="440"/></picture>


| 채널 권한 변경 | 채널 생성 | 채널 탐색 및 참여 | 채널삭제 |
|:---:|:---:|:---:|:---:|
|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/c116efbd-8308-4b25-9966-f11d4c8223b7" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/41691e36-39c7-4b7a-add3-5b1a6e18cd55" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/8bb10ddb-e816-45d5-ab3b-9b3fe3d122e7" width="200" height="440"/></picture>|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/d146d178-6067-41f4-a356-fad6e31c3596" width="200" height="440"/></picture>|

 결제 | 검색
|:---:||:---:|
|<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/aea3c5bb-8690-4cbd-a959-aad793910f71" width="200" height="440"/></picture>||<picture><img src="https://github.com/Little-tale/WorkSpaceX/assets/116441522/610a16a7-f55e-47f9-821b-df08f6b2787e" width="200" height="440"/></picture>|
