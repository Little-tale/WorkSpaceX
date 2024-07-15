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
        
        var channelModel: ChanelEntity?
        
        var progressView: Bool = false
        
        var presentDoc: URL? = nil
        
        var thisLastChatDate: Date = Date()
    }
    
    enum Action {
        // 채팅 분기점
        case chatDate(Date?)
        case channelInfoRequest
        
        case networkResult([WorkSpaceChatEntity])
        case channelResult(ChanelEntity)
        
        case navigationTitle(String) // 전뷰에서 받아왔지만 한번더
        case navigationMemberCount(Int)
        
        case onAppear
        case popClientClicked
        case userFeildText(String)
        
        case realmobserberStart
        
        case errorMessage(String?)
        // 전송
        case sendTapped
        
        // 채팅 모델 변환
        case toChat(WorkSpaceChatEntity)
        
        // 채팅들 액션
//        case chats(IdentifiedActionOf<ChatModeFeature>)
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
        
        case profileImageClikced(ChatModeEntity)
        case fileClicked(urlString: String)
        case progressView(Bool)
        case presentDoc(URL?)
        case delegate(Delegate)
        
        // 상위뷰 관찰
        enum Delegate {
            case popClicked
            case sendToList(channel: ChanelEntity, isOwner: Bool)
            case otehrUserProfile(userID: String)
        }
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workSpaceReader) var reader
    @Dependency(\.fileManager) var fileManager
    
    var body: some ReducerOf<Self> {
        
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                let channelID = state.channelID
                
                let bool = state.onAppearTrigger
                state.onAppearTrigger = false
                
                return .run { send in
                    
                    await send(.channelInfoRequest)
                    
                    if !bool { return }
                    
                    let date = try await realmRepo.findChatsForChannel(channelId: channelID)
                    await send(.chatDate(date))
                }
            case let .chatDate(date) :
                let channelId = state.channelID
                let workSpaceId = state.workSpaceID
                
                if let date {
                    state.lastFetchDate = date
                    return .run { send in
                    
                        try await Task.sleep(for: .seconds(0.1))
                        await send(.firstInit)
                        let result = try await workSpaceRepo.workSpaceChattingList(workSpaceId, channelId, date)
                        
                        await send(.networkResult(result))
                        await send(.socketConnected)
                    } catch: { error, send in
                        if let error = error as? WorkSpaceChannelListAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(error.message))
                            }
                        } else {
                            print(error)
                        }
                    }
                } else {
                    return .run { send in
                        
                        let result = try await workSpaceRepo.workSpaceChattingList(workSpaceId, channelId, nil)
                        print("받기 \(result)")
                        await send(.networkResult(result))
                        
                        // 처음 렘
                        await send(.firstInit)

                        try await Task.sleep(for: .seconds(0.5))
                        await send(.socketConnected)
                    } catch: { error, send in
                        if let error = error as? WorkSpaceChannelListAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(error.message))
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
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        }
                    } else {
                        print("체널 에러 발생 이긴함. ",error)
                    }
                }
                
            case let .channelResult(channel):
                state.channelModel = channel
                state.ownerID = channel.owner_id
                
                state.navigationTitle = channel.name
                
                return .run { send in
                    await send(.navigationMemberCount(channel.users.count))
                }
                
            case let .userFeildText(text):
                state.userFeildText = text
                
                /// 처음엔
            case .firstInit:
                let channelID = state.channelID
                let meID = state.userID
                
                return .run { @MainActor send in
                    
                    if let result = try await realmRepo.findChatsForChannelModel(channelId: channelID, ifRealm: nil) {
                        
                        let chatMessages = Array(result.chatMessages)
                        
                        let entitys = try await realmRepo.toChat(
                            chatMessages,
                            userID: meID
                        )
                        
                        send(.showChats(entitys))
                    } else {
                        send(.showChats([]))
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
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .appendChat(models):
                for model in models {
                    state.currentModels.append(model)
                }
                state.thisLastChatDate = models.last?.date ?? Date()
            case let .showChats(models):
                dump(models)
                if let first = models.first {
                    state.thisLastChatDate = first.date
                } else {
                    state.thisLastChatDate = Date()
                }
                state.currentModels = models

                
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
                            
                            await send(.toChat(model))
                            
                            try await realmRepo.upsertToChatInChannel(models: [model])
                            print("마지막 소켓 model 받음")
                        case .failure(let error):
                            print("마지막 소켓 에러 발생\(error)")
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
                if let owner = state.ownerID,
                   let chatmodel = state.channelModel {
                    let ifOwner = owner == state.userID
                    return .run { send in
                        await send(.delegate(.sendToList(channel: chatmodel, isOwner: ifOwner)))
                    }
                }
            case let .navigationMemberCount(count):
                state.navigationMemberCount = String(count)
                
            case .popClientClicked:
                let channelID = state.channelID
                return .run { send in
                    try await realmRepo.upsertToChatDate(channelID: channelID)
                    await send(.delegate(.popClicked))
                } catch: { error, _ in
                    print(error)
                }
                
            case let .profileImageClikced(model):
                
                guard case let .other(member) = model.isMe else {
                    break
                }
                
                return .run { send in
                    await send(.delegate(.otehrUserProfile(userID: member.userID)))
                }
                
            case let .fileClicked(string):
                
                return .run { send in
                    await send(.progressView(true))
                    do {
                        guard let fileData = try await workSpaceRepo.fileDownload(urlString: string) else {
                            await send(.progressView(false))
                            return
                        }
                        guard let url = fileManager.fileSave(
                            fileData,
                            urlString: string
                        ) else {
                            await send(.progressView(false))
                            return
                        }
                        await send(.progressView(false))
                        await send(.presentDoc(url))
                    } catch {
                        await send(.progressView(false))
                        print(error)
                    }
                }
                
            case let .progressView(bool):
                state.progressView = bool
                
            case let .presentDoc(url):
                state.presentDoc = url
                
            case let .toChat(model):
                let modelDate = model.createdAt.toDate ?? Date()
                let beforeDate = state.thisLastChatDate
                let trigger = isSameDay(modelDate, beforeDate)
                let userID = state.userID
                
                
                let mapping = workSpaceRepo.toChat(
                    model: model,
                    userID: userID,
                    isFirstDate: !trigger
                )
                return .run { send in
                    await send(.appendChat([mapping]))
                }
                
            default:
                break
            }
            return .none
        }
        
    }
    
}

extension WorkSpaceChannelChattingFeature {
    
    private func fileType(from url: URL) -> FileType {
        let fileEx = url.pathExtension.lowercased()
        return FileType(rawValue: fileEx) ?? .unknown
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}
