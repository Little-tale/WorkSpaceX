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
        
        let channelID: String
        let workSpaceID: String
        let userID : String
        
        var navigationTitle: String
        var navigationMemberCount: String = "0"
        
        var userFeildText: String = ""
        var currentDatas: [Data] = []
        
        var chatStates: IdentifiedArrayOf<ChatModeFeature.State> = []
        
        var scrollTo: String = ""
        var lastFetchDate: Date = Date()
        
        var currentModels: [ChatModeEntity] = []
        
        var errorMessage: String? = nil
    }
    
    enum Action {
        
        case popClicked
        
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
        
        case imageDataPicks([Data])
        
        case errorMessage(String?)
        
        // 전송
        case sendTapped
        
        // 채팅들 액션
        case chats(IdentifiedActionOf<ChatModeFeature>)
        case firstInit
        case showChats([ChatModeEntity])
        case appendChat(ChatModeEntity)
        
        // ONCHANGED 이슈로 인한
        case onChangeForScroll(String)
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workSpaceReader) var reader
    
    var body: some ReducerOf<Self> {
        
        
        Reduce { state, action in
            switch action {
            case .onAppear:
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
                    return .run { send in
                        await send(.channelInfoRequest)
                        
                        await send(.firstInit)
                        await send(.realmobserberStart)
                        let result = try await workSpaceRepo.workSpaceChattingList(workSpaceId, channelId, nil)
                        
                        await send(.networkResult(result))
                        
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
                let channelID = state.channelID
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
//                let files = state.currentDatas
                let multi = ChatMultipart(content: content, files: nil)
                state.userFeildText = ""
                
                // 파일이나 텍스트가 없을땐 보내지 않도록 하게 해야함...
                
                return .run { send in
                    // 소켓을 연결할것으로 예상됨으로. 패스.
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
                    
                    for await model in await reader.observeNewMessage(channelID: channelID) {
                        if let result = realmRepo.toChat(model, userID: userID) {
                            
                            try await Task.sleep(for: .seconds(0.03))
                            send(.appendChat(result))
                        }
                    }
                }
                
            case let .appendChat(model):
                state.currentModels.insert(model, at: 0)
                let chatState = ChatModeFeature.State(model: model)
                state.chatStates.append(chatState)
                
            case let .showChats(models):
                dump(models)
                state.currentModels = models
                let states = state.currentModels.map { ChatModeFeature.State(model: $0) }
                state.chatStates.append(contentsOf: states)
                
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .onChangeForScroll(string):
                state.scrollTo = string
                
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


// 3. 있다면 커서 데이트를 쿼리 스트링으로 보내야함.
// 확인하면서 채널을 생성해버림과 동시에 워크스페이스에 연결
// 이유는 간단. 해당 뷰로 오면 이미 사용자는 해당 멤버
// print("네트워크 요청해야함...")
