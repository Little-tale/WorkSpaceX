//
//  DMSChatFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMSChatFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID = UUID()
        
        var onAppearTrigger = true
        
        let workSpaceID: String
        let userID : String
        
        let otherUserID: String
        
        var navigationTitle: String = ""
        var roomID: String? = nil
        
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
        
        var ifDeleteRoom: Bool = false
        
        var progressView: Bool = false
        
        var presentDoc: URL? = nil
        
        var thisLastChatDate: Date = Date()
    }
    
    enum Action {
    
        case popClick
    
        // 채팅 분기점
        case chatDate(Date?)
        
        case roomToEntity(DMSRoomRealmModel?)
        case catchToDMSRoomEntity(DMSRoomEntity)
        case userInfoReqeust(memberID: String)
        case networkResult([DMSChatEntity])
        
        case navigationTitle(String) // 전뷰에서 받아왔지만 한번더
        case navigationMemberCount(Int)
        
        case onAppear
        case userFeildText(String)
        
        case realmobserberStart
        case firstInit
        
        case errorMessage(String?)
        // 전송
        case sendTapped
        case ifDeleteRoom(Bool)
        // 채팅들 액션
        
        case showChats([ChatModeEntity])
        case appendChat([ChatModeEntity])
        case socketTORealm(DMSChatEntity, String)
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
        
        case userInfoResult(WorkSpaceMembersEntity)
        case socketConnected
        
        case delegate(Delegate)
        
        case profileImageClikced(ChatModeEntity)
        
        case fileClicked(urlString: String)
        
        case progressView(Bool)
        
        case presentDoc(URL?)
        
        case toChatModel(DMSChatEntity)
        
        enum Delegate {
            case popClicked(roomID: String)
            case otherUserProfile(userID: String)
        }
    }
    @Dependency(\.workspaceDomainRepository) var workRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workSpaceReader) var reader
    @Dependency(\.dmsRepository) var dmsRepo
    @Dependency(\.fileManager) var fileManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                
                let workSpaceID = state.workSpaceID
                let userId = state.otherUserID
                let bool = state.onAppearTrigger
//                let member = state.toModelEntity
                state.onAppearTrigger = false
                
                return .run { @MainActor send in
                    send(.userInfoReqeust(memberID: userId))
                    if !bool { return }
                    
                    let ifRealm = try await realmRepo.findDMSRoom(
                        workSpaceID: workSpaceID,
                        userId
                    )
                    send(.roomToEntity(ifRealm))
                    
                }
            case let .roomToEntity(model):
                let workSpaceID = state.workSpaceID
                let userId = state.otherUserID
                if let model {
                    state.roomID = model.roomId
                    let entity = dmsRepo.dmsRealmToEntity(model)
                    // 룸 아이디는 그대로일 것으로 보임 즉 최초로 한번만 룸에 대해서 조사 후 DM 연결해야 함
                    return .run { send in
                        await send(.catchToDMSRoomEntity(entity))
//                        await send(.realmobserberStart)
                        
                    }
                } else {
                    return .run { send in
                        let result = try await dmsRepo.dmsRoomRequest(
                            workSpaceID,
                            otherUserID: userId
                        )
                        try await realmRepo.upsertDMSRoomEntity(
                            result,
                            workSpaceID: workSpaceID
                        )
                        await send(.catchToDMSRoomEntity(result))
                        
//                        await send(.realmobserberStart)
                        
                    } catch: { error, send in
                        if let error = error as? DMSRoomAPIError {
                            if !error.ifDevelopError {
                                await send(.errorMessage(error.message))
                            }
                            if error.ifDevelopError {
                                await send(.ifDeleteRoom(true))
                            }
                        } else {
                            print(error)
                        }
                    }
                }
            case let .catchToDMSRoomEntity(model):
                print(model)
                state.roomID = model.roomId
                let roomID = model.roomId
                let id = state.workSpaceID
    
                guard id != "" else { break }
                return .run { send in
                    
                    let date = try await realmRepo.findDMSChatLastDate(roomID: roomID)
                    if let date {
                        await send(.firstInit)
                        let date = DateManager.shared.toDateISO(date)
                        let result = try await dmsRepo.dmsChatListRquest(
                            model.roomId,
                            workSpaceId: id,
                            cursurDate: date
                        )
                        await send(.networkResult(result))
                        await send(.socketConnected)
                    } else {
                        let result = try await dmsRepo.dmsChatListRquest(
                            model.roomId,
                            workSpaceId: id,
                            cursurDate: nil
                        )
                        await send(.networkResult(result))
                        await send(.firstInit)
                        await send(.socketConnected)
                    }
                } catch: { error, send in
                    if let error = error as? DMSListAPIError{
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                            if error.ifDevelopError {
                                await send(.ifDeleteRoom(true))
                            }
                        } else {
                            print(error)
                        }
                    } else { print(error) }
                }
                
            case let .networkResult(results):
                print("네트워크",results)
                if let roomID = state.roomID {
                    return .run { send in
                        try await realmRepo.upsertToDMSChats(
                            models: results,
                            roomID: roomID
                        )
                        
                    } catch: { error, send in
                        print(error)
                    }
                }
            case .firstInit:
                if let roomID = state.roomID {
                    let meID = state.userID
                    return .run { @MainActor send in
                        
                        let result = try await realmRepo.findDMSChats(
                            roomID: roomID
                        )
                        
                        let entitys = try await realmRepo.toChat(
                            result,
                            userID: meID
                        )
                        
                        send(.showChats(entitys))
                    }
                }
            case let .userInfoReqeust(memberId):
                return .run { @MainActor send in
                    let result = try await workRepo.requestUserInfo(
                        userID: memberId
                        // 렘에 업데이트하고 가져오는게 낳을것 같음
                    )
                    
                    let realm = try await realmRepo.upsertMembers(response: result)
                    
                    if let realm {
                        let model = realmRepo.userToMember(realm)
                        send(.userInfoResult(model))
                    } else {
                        send(.userInfoResult(result))
                    }
//                    await send(.userInfoResult(result))
                } catch: { error, send in
                    if let error = error as? UserInfoRequestAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }

            case .sendTapped:
                if state.ifDeleteRoom {
                    break
                }
                
                guard let roomId = state.roomID else { break }
                let workSpaceID = state.workSpaceID
                
                let content = state.userFeildText
                let files = state.currentDatas
                
                if content == "" && files.isEmpty {
                    break
                }
                let multi = ChatMultipart(content: content, files: files)
                state.userFeildText = ""
                state.currentDatas = []
                return .run { send in
                    await send(.dataCountChaeck)
                    // 소켓을 통해 받을 예정
                    try await dmsRepo.sendChatRequest(
                        workSpaceID,
                        roomID: roomId,
                        request: multi
                    )
                } catch: { error, send in
                    if let error = error as? DMSRoomAPIError {
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
                state.currentModels.append(contentsOf: models)
                
            case let .showChats(models):
                if let last = models.last {
                    state.thisLastChatDate = last.date
                }
                state.currentModels = models
                
            case let .userFeildText(text):
                state.userFeildText = text
                
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
                let roomID = state.roomID
                guard let roomID else { break }
                return .run { send in
                    for await result in dmsRepo.dmSocketRequest(roomID) {
                        switch result {
                        case let .success(model):
                            await send(.toChatModel(model))
                            Task.detached {
                                await send(.socketTORealm(model, roomID))
                            }
                        case let .failure(error):
                            print(error)
                            await send(.errorMessage(error.message))
                        }
                    }
                } catch: { error, send in
                    print("소켓 렘 에러",error) // 렘 에러.
                }
                
            case let .socketTORealm(model, roomID):
                return .run { send in
                    try await realmRepo.upsertToDMSChats(
                        models: [model],
                        roomID: roomID
                    )
                } catch: { error, send in
                    print(error)
                }
                
                // 알렛 메시지
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .onChangeForScroll(string):
                state.scrollTo = string
                
            case let .userInfoResult(model):
                state.navigationTitle = model.nickname
            case .popClick:
                if let roomID = state.roomID {
                    return .run { send in
                        try await realmRepo.upsertToDMSDate(roomID:roomID)
                        await send(.delegate(.popClicked(roomID: roomID)))
                    } catch: { error, send in
                        print(error)
                    }
                }
            case let .toChatModel(model):
                let modelDate = model.createdAt.toDate ?? Date()
                let beforeDate = state.thisLastChatDate
                let trigger = isSameDay(modelDate, beforeDate)
                let userID = state.userID
                
                let mapping = dmsRepo.toChat(
                    model,
                    userID: userID,
                    isFirstDate: !trigger
                )
                state.thisLastChatDate = modelDate
                
                return .run { send in
                    await send(.appendChat([mapping]))
                }
                
            case let .ifDeleteRoom(bool):
                state.ifDeleteRoom = bool
                
            case let .profileImageClikced(model):
                
                guard case let .other(member) = model.isMe else {
                    break
                }
                
                return .run { send in
                    await send(.delegate(.otherUserProfile(userID: member.userID)))
                }
                
            case let .fileClicked(string):
                
                return .run { send in
                    await send(.progressView(true))
                    do {
                        guard let fileData = try await workRepo.fileDownload(urlString: string) else {
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
                
            default:
                break
            }
            return .none
        }
    }
    
}

extension DMSChatFeature {
    
    private func fileType(from url: URL) -> FileType {
        let fileEx = url.pathExtension.lowercased()
        return FileType(rawValue: fileEx) ?? .unknown
    }
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

// 1. 채팅 데이터가 존재하는지 최소한 한번은 확인해야함.
// 1.0.1 렘 페이지 네이션을 위해. 날짜별 호출 먼저 최초 1회 후
// 1.1 채팅 존재한다면 바로 렘 옵저버 걸기
// 2. 없다면 커서 데이트를 빈값으로 보내야함.
// 1.2 없다면 네트워크 먼저 수행후 렘 옵저버 걸기
// + 렘 멤버 도 꼭 확인
/// 렘 옵저버를 바로볼 필요가 있는가?
//            case .realmobserberStart:
//                if let roomID = state.roomID {
////                    let userID = state.userID
////                    return .run { @MainActor send in
////                        for await models in  reader.observeNewMessage(
////                            dmRoomID: roomID
////                        ) {
////                            let result = try await realmRepo.toChat(models, userID: userID)
////                            send(.appendChat(result))
////                        }
////                    }
//                }
