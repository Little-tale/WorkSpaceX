//
//  WorkSpaceChannelChattingFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceChannelChattingFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID = UUID()
        
        var onAppearTrigger = true
        
        let channelID: String
        let workSpaceID: String
        let userID : String
        
        var navigationTitle: String
        var navigationMemberCount: String = "0"
        
        var userFeildText: String = ""
        var currentDatas: [ChatMultipart.File] = []
        var showChatBottom: Bool = false
        
        var chatStates: IdentifiedArrayOf<ChatModeFeature.State> = []
        
        var scrollTo: String = ""
        var lastFetchDate: Date? = nil
        
        var currentModels: [ChatModeEntity] = []
        
        var errorMessage: String? = nil
        
        /// 이미지 피커 트리거
        var imagePickerTrigger: Bool = false
        /// 파일 피커 트리거
        var filePickerTrigger: Bool = false
        
        // 데이터 관리 카운트
        var dataCanCount: Int = 5
        
        var ownerID: String?
    }
    
    enum Action {
        // 상위뷰 관찰
        case popClicked
        case sendToList(channelID: String, isOwner: Bool)
        
        // 채팅 분기점
        case chatDate(Date?)
        case channelInfoRequest
        
        case networkResult([WorkSpaceChatEntity])
        case channelResult(ChanelEntity)
        
        case navigationTitle(String) // 전뷰에서 받아왔지만 한번더
        case navigationMemberCount(Int)
        
        case onAppear
        case userFeildText(String)
        
        case realmobserberStart
        
        case errorMessage(String?)
        // 전송
        case sendTapped
        
        // 채팅들 액션
        case chats(IdentifiedActionOf<ChatModeFeature>)
        case firstInit
        case showChats([ChatModeEntity])
        case appendChat([ChatModeEntity])
        
        // ONCHANGED 이슈로 인한
        case onChangeForScroll(String)
        
        // 데이터 카운터 관리
        case dataCountChaeck
        // 데이터 제거 관리
        case dataRemoveToIndex(Int)
        // 이미지 피커
        case showImagePicker
        case imageDataPicks([Data])
        case imagePickerBool(Bool)
        case imagePickerCanCount(Int)
        
        // 파일 피커
        case showFilePicker
        case filePickerBool(Bool)
        case filePickOver
        case filePickerResults([URL])
        
        case socketConnected
        case listButtonTapped
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workSpaceReader) var reader
    
    var body: some ReducerOf<Self> {
        
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.onAppearTrigger { break }
                state.onAppearTrigger = false
                let channelID = state.channelID
                
                let workSpaceID = state.workSpaceID
                
                // 1. 채팅 데이터가 존재하는지 최소한 한번은 확인해야함.
                // 1.0.1 렘 페이지 네이션을 위해. 날짜별 호출 먼저 최초 1회 후
                // 1.1 채팅 존재한다면 바로 렘 옵저버 걸기
                // 2. 없다면 커서 데이트를 빈값으로 보내야함.
                // 1.2 없다면 네트워크 먼저 수행후 렘 옵저버 걸기
                // + 렘 멤버 도 꼭 확인
                return .run { send in
                    
                    let date = try await realmRepo.findChatsForChannel(channelId: channelID)
                    await send(.chatDate(date))
                }
            case let .chatDate(date) :
                let channelId = state.channelID
                let workSpaceId = state.workSpaceID
                
                if let date {
                    // 1.1 채팅 존재한다면 바로 렘 옵저버 걸기
                    // 렘옵저버 선 후 -> 통신
                    state.lastFetchDate = date
                    return .run { send in
                        
                        await send(.channelInfoRequest)
                        
                        await send(.firstInit)
                        await send(.realmobserberStart)
                        let result = try await workSpaceRepo.workSpaceChattingList(workSpaceId, channelId, date)
                        
                        await send(.networkResult(result))
                        await send(.socketConnected)
                    }
                } else {
                    // 2. 없다면 커서 데이트를 빈값으로 보내야함.
                    // 1.2 없다면 네트워크 먼저 수행후 렘 옵저버 걸기
                    return .run { send in
                        let result = try await workSpaceRepo.workSpaceChattingList(workSpaceId, channelId, nil)
                        print("받기 \(result)")
                        await send(.networkResult(result))
                        await send(.channelInfoRequest)
                        // 처음 렘
                        await send(.firstInit)
                        await send(.realmobserberStart)
                        await send(.socketConnected)
                    } catch: { error, send in
                        if let error = error as? WorkSpaceChannelListAPIError {
                            if error.ifReFreshDead { RefreshTokkenDeadReciver.shared.postRefreshTokenDead() }
                            else if error.errorCode == "E13" {
                                print("존재하지 않는 워크 스페이스..?")
                            }
                        } else {
                            print(error)
                        }
                    }
                }
            case let .networkResult(results):
                print("네트워크",results)
                //let channelID = state.channelID
                // [WorkSpaceChatEntity]
                return .run { send in
                    try await realmRepo.upsertToChatInChannel( models: results)
                }
                //채널 정보 조회
            case .channelInfoRequest:
                let workSpaceID = state.workSpaceID
                let channelID = state.channelID
                return .run { send in
                    let result = try await workSpaceRepo.channelInfoRequest(workSpaceID, channelID)
                    await send(.channelResult(result))
                    // 이때 렘 업뎃
                    try await  realmRepo.upsertToWorkSpaceChannelAppend(workSpaceID: workSpaceID, chanel: result, userBool: true)
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceChannelListAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .channelResult(channel):
                state.navigationMemberCount = String(channel.users.count)
                state.ownerID = channel.owner_id
                break
                
            case let .chats(.element(id: _, action: .delegate(.selectedFileURLString(text)))):
                print(text)
                
            case let .userFeildText(text):
                state.userFeildText = text
                
                /// 처음엔
            case .firstInit:
                let channelID = state.channelID
                let meID = state.userID
                
                return .run { @MainActor send in
                    
                    if let result = try await realmRepo.findChatsForChannelModel(channelId: channelID, ifRealm: nil) {
                        
                        let chatMessages = Array(result.chatMessages)
                        
                        let entitys = realmRepo.toChat(chatMessages, userID: meID)
                        
                        send(.showChats(entitys))
                    }
                }
            case .sendTapped:
                let workSpaceID = state.workSpaceID
                let channelID = state.channelID
                let content = state.userFeildText
                let files = state.currentDatas
                
                if content == "" && files.isEmpty {
                    break
                }
                let multi = ChatMultipart(content: content, files: files)
                state.userFeildText = ""
                state.currentDatas = []
                // 파일이나 텍스트가 없을땐 보내지 않도록 하게 해야함...
                
                return .run { send in
                    // 소켓을 연결할것으로 예상됨으로. 패스.
                    await send(.dataCountChaeck)
                    let result = try await workSpaceRepo.sendChatting(
                        workSpaceID,
                        channelID,
                        multi
                    )
                    print("전송은 성공 : ",result)
                } catch: { error, send in
                    if let error = error as? WorkSpaceChatSendAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case .realmobserberStart:
                let channelID = state.channelID
                let userID = state.userID
                return .run { @MainActor send in
                    
                    for await model in  reader.observeNewMessage(channelID: channelID) {
                        
                        let result = model.compactMap { @MainActor model in
                            realmRepo.toChat(model, userID: userID)
                        }
                        send(.appendChat(result))
                    }
                }
                
            case let .appendChat(models):
                var chatStates: [ChatModeFeature.State] = []
                for model in models {
                    state.currentModels.insert(model, at: 0)
                    chatStates.append(ChatModeFeature.State(model: model))
                }
                state.chatStates.append(contentsOf: chatStates)
                
            case let .showChats(models):
                dump(models)
                state.currentModels = models
                let states = state.currentModels.map { ChatModeFeature.State(model: $0) }
                state.chatStates.append(contentsOf: states)
                
                
                // 이미지 피커란
            case .showImagePicker:
                if state.dataCanCount == 0 {
                    return .run { send in await send(.filePickOver)}
                }
                return .run { send in
                    await send(.imagePickerBool(true))
                }
            case let .imagePickerBool(bool):
                state.imagePickerTrigger = bool
                // 이미지 피커 데이터
            case let .imageDataPicks(datas):
                
                let multiToImage = datas.map { data in
                    ChatMultipart.File(
                        data: data,
                        fileName: "WorkSpaceX_\(UUID()).jpeg",
                        fileType: .image
                    )
                }
                state.currentDatas.append(contentsOf: multiToImage)
                return .run { send in
                    await send(.dataCountChaeck)
                }
                
            case .showFilePicker:
                return .run { send in
                    await send(.filePickerBool(true))
                }
            case let .filePickerBool(bool):
                if state.dataCanCount == 0 {
                    return .run { send in await send(.filePickOver)}
                }
                state.filePickerTrigger = bool
                
            case let .filePickerResults(urls):
                var datas: [ChatMultipart.File] = []
                var ifOberData: Bool = false
                for url in urls {
                    guard let data = try? Data(contentsOf: url) else { continue }
                    let dataSize = Double(data.count)
                    if dataSize > (4.99 * 1024 * 1024) {
                        ifOberData = true
                        continue
                    }
                    let fileName: String = url.lastPathComponent
                    let filType = fileType(from: url)
                    let result = ChatMultipart.File(
                        data: data,
                        fileName: fileName,
                        fileType: filType
                    )
                    datas.append(result)
                }
                
                state.currentDatas.append(contentsOf: datas)
                
                if ifOberData {
                    return .run { send in
                        await send(.dataCountChaeck)
                        await send(.errorMessage("5mb 초과 데이터는 추가하실 수 없습니다!"))
                    }
                } else {
                    return .run { send in
                        await send(.dataCountChaeck)
                    }
                }
            case .filePickOver:
                state.errorMessage = "총 5개 제한 이에요 ㅠㅠ"

                // 데이터 카운트 관리
            case .dataCountChaeck:
                state.dataCanCount = 5 - state.currentDatas.count
                let bool = state.currentDatas.count > 0
                state.showChatBottom = bool
               
                // 데이터 삭제 관리
            case let .dataRemoveToIndex(index):
                state.currentDatas.remove(at: index)
                return .run { send in
                    await send(.dataCountChaeck)
                }
            case .socketConnected:
                let channelID = state.channelID
                return .run { send in
                    for await result in  workSpaceRepo.channelSocketReqeust(channelID) {
                        switch result {
                        case let .success(model):
                            try await realmRepo.upsertToChatInChannel(models: [model])
                            print("마지막 소켓 model 받음")
                        case .failure(let error):
                            print("마지막 소켓 에러 발생")
                            await send(.errorMessage(error.message))
                        }
                    }
                } catch: { error, send in
                    print("소켓 렘 에러",error) // 렘 에러.
                }
                
                // 알렛 메시지
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .onChangeForScroll(string):
                state.scrollTo = string
                
            case .listButtonTapped:
                let channelID = state.channelID
                if let owner = state.ownerID {
                    let ifOwner = owner == state.userID
                    return .run { send in
                        await send(.sendToList(channelID: channelID,isOwner: ifOwner))
                    }
                }
                
                
            default:
                break
            }
            return .none
        }
        .forEach(\.chatStates, action: \.chats) {
            ChatModeFeature()
        }
        
    }
    
}

extension WorkSpaceChannelChattingFeature {
    
    private func fileType(from url: URL) -> FileType {
        let fileEx = url.pathExtension.lowercased()
        return FileType(rawValue: fileEx) ?? .unknown
    }
    
}


// 3. 있다면 커서 데이트를 쿼리 스트링으로 보내야함.
// 확인하면서 채널을 생성해버림과 동시에 워크스페이스에 연결
// 이유는 간단. 해당 뷰로 오면 이미 사용자는 해당 멤버
// print("네트워크 요청해야함...")
