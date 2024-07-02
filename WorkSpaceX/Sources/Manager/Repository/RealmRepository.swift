//
//  RealmRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation
import RealmSwift
import ComposableArchitecture

@MainActor
struct RealmRepository {
    
    @MainActor
    func removeForID<M: Object>(_ modelId: String, type: M.Type) async throws -> Void {
        let realm = try await Realm(actor: MainActor.shared)
        
        guard let object = realm.object(ofType: type, forPrimaryKey: modelId) else {
            throw RealmError.cantFindModel
        }
        
        try await realm.asyncWrite {
            realm.delete(object)
        }
    }
    
    @MainActor
    static func mainActorRemove<M: Object>(_ modelId: String, type: M.Type) async throws {
        let realm = try await Realm(actor: MainActor.shared)
        
        guard let workspace = realm.object(ofType: WorkSpaceRealmModel.self, forPrimaryKey: modelId) else {
            throw RealmError.cantFindModel
        }
        
        try await realm.asyncWrite{
            if let model = realm.object(ofType: type, forPrimaryKey: modelId) {
                realm.delete(workspace.users)
                realm.delete(workspace.channels)
                realm.delete(model)
            }
        }
    }
    @MainActor
    func findModel<M:Object>(_ modelId: String, type: M.Type) async throws -> M? {
        let realm = try await Realm(actor: MainActor.shared)
        let result = realm.object(ofType: M.self, forPrimaryKey: modelId)
        return result
    }
}


extension RealmRepository {
    /// 유저 프로필 정보를 생성하거나 덮어씌웁니다.
    @discardableResult
    func upsertUserModel(response: UserEntity) async throws -> UserRealmModel? {
        let realm = try await Realm(actor: MainActor.shared)
        print("유저 정보 저장중.....")
        do {
            try await realm.asyncWrite {
                realm.create(UserRealmModel.self, value: [
                    "userID" : response.userID,
                    "email" : response.email,
                    "nickName" : response.nickname,
                    "profileImage" : response.profileImage as Any,
                    "phone" : response.phone as Any,
                    "provider" : response.provider as Any,
                    "createdAt" : response.createdAt as Any
                ], update: .modified)
            }
            let result = realm.object(ofType: UserRealmModel.self, forPrimaryKey: response.userID)
            
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    @MainActor
    func upsertWorkSpaces(responses: [WorkSpaceEntity]) async throws {
        try await syncWorkSpaces(with: responses)
    }
    
    /// 워크 스페이스 렘에는 존재하나 서버에 없을때 사용합니다.
    @MainActor
    func syncWorkSpaces(with responses: [WorkSpaceEntity]) async throws {
        let realm = try await Realm(actor: MainActor.shared)
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        print("동기화 .... ")
        
        try await removeForCleantoWorkSpace(
            serverIDs: responses.map { $0.workSpaceID },
            ifRealm: realm
        )

        try await realm.asyncWrite {
            responses.forEach { @MainActor models in
                realm.create(WorkSpaceRealmModel.self, value: [
                    "workSpaceID" : models.workSpaceID,
                    "workSpaceName" : models.name,
                    "introduce" : models.description as Any,
                    "coverImage" : models.coverImage?.absoluteString as Any,
                    "ownerID" : models.ownerID,
                    "createdAt" : models.createdAt.toDate as Any
                ], update: .modified)
            }
            
        }
    }
    
    /// 워크 스페이스 렘에는 존재하나 서버에 없을때 사용합니다.
    @MainActor
    func syncWorkSpace(with responses: [WorkSpaceDetailEntity]) async throws {
        let realm = try await Realm(actor: MainActor.shared)
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        print("동기화 .... ")
        
        try await removeForCleantoWorkSpace(
            serverIDs: responses.map { $0.workSpaceID },
            ifRealm: realm
        )
        
        
        for model in responses {
            var members: [UserRealmModel] = []
            
            for member in model.workSpaceMembersEntitys {
                let result = try await upserWorkMember(response: member, ifRealm: realm)
                
                if let result {
                    members.append(result)
                }
            }
            var channelRealms: [WorkSpaceChannelRealmModel] = []
            
            channelRealms = try await upserWorkSpaceChannels(channels: model.chanelEntitys, ifRealm: realm)
            
            try await realm.asyncWrite {
                realm.create(WorkSpaceRealmModel.self, value: [
                    "workSpaceID" : model.workSpaceID,
                    "workSpaceName" : model.name,
                    "introduce" : model.description as Any,
                    "coverImage" : model.coverImage?.absoluteString as Any,
                    "ownerID" : model.ownerID,
                    "createdAt" : model.createdAt.toDate as Any,
                    "users": members,
                    "channels": channelRealms
                ], update: .modified)
            }
        }
    }
    
    @MainActor
    func removeForCleantoWorkSpace(serverIDs: [String], ifRealm: Realm? = nil) async throws {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        let currentIDs = Set(realm.objects(WorkSpaceRealmModel.self).map{ $0.workSpaceID })
        
        let idsToDelete = currentIDs.subtracting(serverIDs)
        
        let objectsToDelete = realm.objects(WorkSpaceRealmModel.self).filter("workSpaceID IN %@", idsToDelete)
        
        try await realm.asyncWrite {
            objectsToDelete.forEach { @MainActor model in
                realm.delete(model.channels)
            }
            realm.delete(objectsToDelete)
        }
    }
    
    
    /// 워크스페이스를 등록하거나 덮어 씌웁니다.
    @MainActor
    func upsertWorkSpace(response: WorkSpaceEntity) async throws {
        let realm = try await Realm(actor: MainActor.shared)
        print("워크 스페이스 저장중 ....")
        try await realm.asyncWrite {
            realm.create(WorkSpaceRealmModel.self, value: [
                "workSpaceID" : response.workSpaceID,
                "workSpaceName" : response.name,
                "introduce" : response.description as Any,
                "coverImage" : response.coverImage?.absoluteString as Any,
                "ownerID" : response.ownerID,
                "createdAt" : response.createdAt.toDate as Any
            ], update: .modified)
        }
    }
    
    @MainActor
    func upsertWorkSpaceInMember(response: WorkSpaceMembersEntity, workSpaceID: String) async throws {
        
        let realm = try await Realm(actor: MainActor.shared)
        
        let ifRegOrUpdate = try await upserWorkMember(response: response, ifRealm: realm)
        
        guard let ifRegOrUpdate else { throw RealmError.cantFindModel }
        
        let result = realm.object(ofType: WorkSpaceRealmModel.self, forPrimaryKey: workSpaceID)
        
        guard let result else { throw RealmError.cantFindModel }
        
        try await realm.asyncWrite {
            result.users.append(ifRegOrUpdate)
        }
    }
    
    @MainActor
    func upsertWorkSpaceInMembers(responses: [WorkSpaceMembersEntity], workSpaceID: String) async throws {
        
        let realm = try await Realm(actor: MainActor.shared)
        print("렘 : \(Realm.Configuration.defaultConfiguration.fileURL)")
        var users: [UserRealmModel] = []
        
        for response in responses {
            let ifRegOrUpdate = try await upserWorkMember(response: response, ifRealm: realm)
            guard let ifRegOrUpdate else { throw RealmError.cantFindModel }
            users.append(ifRegOrUpdate)
        }
        
        try await realm.asyncWrite {
            realm.create(
                WorkSpaceRealmModel.self,
                value: [
                    "workSpaceID" : workSpaceID,
                    "users": users
                ],
                update: .modified)
        }
    }
    
    @MainActor
    func upserWorkMember(response: WorkSpaceMembersEntity, ifRealm: Realm? = nil) async throws -> UserRealmModel? {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        try await realm.asyncWrite {
            realm.create(
                UserRealmModel.self,
                value: [
                    "userID" : response.userID,
                    "email" : response.email,
                    "nickName" : response.nickname,
                    "profileImage": response.profileImage
                ], update: .modified)
        }
        let result = realm.object(ofType: UserRealmModel.self, forPrimaryKey: response.userID)
        
        return result
    }
    
    @MainActor
    func upsertToWorkSpaceChannels(workSpaceId: String, channels: [ChanelEntity]) async throws {
        let realm = try await Realm(actor: MainActor.shared)
        print("워크스페이스 채널 업데이트중 ....")
        
        let channelUpdate = try await upserWorkSpaceChannels(channels: channels, ifRealm: realm)
        
        try await realm.asyncWrite {
            realm.create(
                WorkSpaceRealmModel.self,
                value: [
                    "workSpaceID" : workSpaceId,
                    "channels": channelUpdate
                ],
                update: .modified)
        }
    }
    
    @MainActor
    func findMembers(workSpaceID: String) async throws -> [UserRealmModel]{
        let realm = try await Realm(actor: MainActor.shared)
        
        let model = realm.object(ofType: WorkSpaceRealmModel.self, forPrimaryKey: workSpaceID)
        if let model {
            let array = Array(model.users)
            return array 
        } else {
            return []
        }
        
    }
    
    @MainActor
    @discardableResult
    func upsertToWorkSpaceChannelAppend(workSpaceID: String, chanel: ChanelEntity, userBool: Bool = false) async throws -> ChanelEntity {
        
        let realm = try await Realm(actor: MainActor.shared)
        
        guard let channelModel = try await upserWorkSpaceChannel(channel: chanel, ifRealm: realm)
        else {
            throw RealmError.failAdd
        }
        
        // 기존 워크스페이스 모델 가져오기
        guard let workSpaceModel = realm.object(ofType: WorkSpaceRealmModel.self, forPrimaryKey: workSpaceID) else {
            throw RealmError.cantFindModel
        }
        
        if userBool {
            let users = try await upsertWorkSpaceUsers(users: chanel.users)
            var update = Array(workSpaceModel.channels)
            
            if let index = update.firstIndex(where: { $0.channelID == channelModel.channelID }) {
                update[index] = channelModel  // 기존 채널 업데이트
            } else {
                update.append(channelModel)  // 새로운 채널 추가
            }
            
            try await realm.asyncWrite {
                realm.create(
                    WorkSpaceRealmModel.self,
                    value: [
                        "workSpaceID" : workSpaceID,
                        "channels": update,
                        "users": users
                    ],
                    update: .modified)
                
            }
            return chanel
        } else {
            
            var update = Array(workSpaceModel.channels)
            
            if let index = update.firstIndex(where: { $0.channelID == channelModel.channelID }) {
                update[index] = channelModel  // 기존 채널 업데이트
            } else {
                update.append(channelModel)  // 새로운 채널 추가
            }
            
            try await realm.asyncWrite {
        
                realm.create(
                    WorkSpaceRealmModel.self,
                    value: [
                        "workSpaceID" : workSpaceID,
                        "channels": update
                    ],
                    update: .modified)
            }
            return chanel
        }
    }
    
    func upsertWorkSpaceUsers(users: [WorkSpaceMembersEntity]) async throws -> [UserRealmModel] {
        
        var userRealmModels: [UserRealmModel] = []
        
        for user in users {
            if let userModel = try await upsertMembers(response: user) {
                userRealmModels.append(userModel)
            }
        }
        return userRealmModels
    }
    
    @discardableResult
    func upsertMembers(response: WorkSpaceMembersEntity, ifRealm: Realm? = nil) async throws -> UserRealmModel? {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        print("유저 정보 저장중.....")
        do {
            try await realm.asyncWrite {
                realm.create(UserRealmModel.self, value: [
                    "userID" : response.userID,
                    "email" : response.email,
                    "nickName" : response.nickname,
                    "profileImage" : response.profileImage as Any,
                ], update: .modified)
            }
            let result = realm.object(ofType: UserRealmModel.self, forPrimaryKey: response.userID)
            
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    @MainActor
    @discardableResult
    func upserWorkSpaceChannels(channels: [ChanelEntity], ifRealm: Realm? = nil) async throws -> [WorkSpaceChannelRealmModel] {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        print("워크 스페이스 체널 저장과 동기화 ....")
        
        var results: [WorkSpaceChannelRealmModel] = []
        var ifremove: [WorkSpaceChannelRealmModel] = []
        
        let currentIDs = Set(realm.objects(WorkSpaceChannelRealmModel.self).map{ $0.channelID })
        
        let serverIDs = channels.map { $0.channelId }
        
        let idsToDelete = currentIDs.subtracting(serverIDs)
        
        let objectsToDelete = realm.objects(WorkSpaceChannelRealmModel.self).filter("channelID IN %@", idsToDelete)
        
        ifremove.append(contentsOf: Array(objectsToDelete))
        
        for model in ifremove {
            await WorkSpaceReader.shared.observeChannelStop(model.channelID)
        }
        
        try await realm.asyncWrite { // 서버에 없는것 부터 제거
            realm.delete(objectsToDelete)
        }
        
        for entity in channels {
            let result = try await upserWorkSpaceChannel(channel: entity, ifRealm: realm)
            
            if let result {
                results.append(result)
            }
        }
        return results
    }
    
    @MainActor
    @discardableResult
    func upserWorkSpaceChannel(channel: ChanelEntity, ifRealm: Realm? = nil) async throws ->  WorkSpaceChannelRealmModel? {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        try await realm.asyncWrite {
            realm.create(WorkSpaceChannelRealmModel.self, value: [
                "channelID" : channel.channelId,
                "name" : channel.name,
                "introduce" : channel.description as Any,
                "coverImage" : channel.coverImage as Any,
                "ownerID" : channel.owner_id,
                "createdAt" : channel.createdAt.toDate as Any
            ], update: .modified)
        }
        
        if let model = realm.object(ofType: WorkSpaceChannelRealmModel.self, forPrimaryKey: channel.channelId) {
            return model
        }
        return nil
    }
}

extension RealmRepository {
    func findChatsForChannel(channelId: String, ifRealm: Realm? = nil) async throws -> Date?  {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        guard let model = try await findChatsForChannelModel(channelId: channelId, ifRealm: realm) else {
            return nil
        }
        
        let first = model.chatMessages.sorted(by: \.createdAt, ascending: false)
            .first
        guard let first else { return nil }
        
        return first.createdAt
    }
    // DMS 모델이 존재하는가?
    func findDMSRoom(workSpaceID: String,_ userID: String, _ ifRealm: Realm? = nil) async throws -> DMSRoomRealmModel? {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        let results = realm.objects(DMSRoomRealmModel.self).where {
            $0.workSpaceID == workSpaceID && $0.userID == userID
        }
        return results.first
    }
    func findDMSRoom(roomID: String, _ ifRealm: Realm? = nil) async throws -> DMSRoomRealmModel? {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }

        let result = realm.object(ofType: DMSRoomRealmModel.self, forPrimaryKey: roomID)
        return result
    }
    
    func findChatsForChannelModel(channelId: String, ifRealm: Realm? = nil) async throws -> WorkSpaceChannelRealmModel?  {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
    
        let model = realm.object(ofType: WorkSpaceChannelRealmModel.self, forPrimaryKey: channelId)
        
        guard let model else { return nil }
        print("//??",model)
        return model
    }
    
    @MainActor
    func findDMSChats(roomID: String, ifRealm: Realm? = nil) async throws -> [DMChatRealmModel]  {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
    
        let model = realm.object(ofType: DMSRoomRealmModel.self, forPrimaryKey: roomID)?.chatMessages
        
        guard let model else { return [] }
        
        print("//??",model)
        return Array(model)
    }
    
}

extension RealmRepository {
    
    func upsertToChatInChannel(models: [WorkSpaceChatEntity]) async throws {
        
        guard let first = models.first else { return }
        
        let realm = try await Realm(actor: MainActor.shared)
        
        guard let channel = try await findChatsForChannelModel(channelId: first.channelId, ifRealm: realm) else {
            throw RealmError.cantFindModel
        }
        
        let cancelUpdate = Set(channel.chatMessages.map { $0.chatID })
        
        var chatModels = [ChatRealmModel]()
        var lastDate: Date? = nil
        
        // 채팅 메시지의 마지막 날짜를 가져옵니다.
        let allChats = channel.chatMessages.sorted(byKeyPath: "createdAt", ascending: true)
        if let lastChat = allChats.last {
            lastDate = Calendar.current.startOfDay(for: lastChat.createdAt ?? Date())
        }
        
        for chat in models {
            if cancelUpdate.contains(chat.chatId) {
                continue
            }
            guard let user = try await upsertMembers(response: chat.user, ifRealm: realm) else {
                throw RealmError.failAdd
            }
            let newChat = try await upsertChat(chat, user: user, ifRealm: realm)
            
            chatModels.append(newChat)
        }
        
        try await realm.asyncWrite {
            for chatModel in chatModels {
                let chatDate = Calendar.current.startOfDay(for: chatModel.createdAt ?? Date())
                
                if lastDate != chatDate {
                    chatModel.isDateSection = true
                    lastDate = chatDate
                } else {
                    chatModel.isDateSection = false
                }
                
                realm.add(chatModel, update: .modified)
            }
            
            channel.chatMessages.append(objectsIn: chatModels)
        }
    }
}
extension RealmRepository {
    
    func upsertToDMSChats(models: [DMSChatEntity], roomID: String) async throws {
        
        guard let first = models.first else { return }
        
        let realm = try await Realm(actor: MainActor.shared)
        
        guard let dmsRoom = try await findDMSRoom(
            roomID: roomID, realm
        ) else {
            throw RealmError.cantFindModel
        }
        
        let cancelUpdate = Set(dmsRoom.chatMessages.map { $0.dmID })
        
        var chatModels = [DMChatRealmModel]()
        var lastDate: Date? = nil
        
        // 채팅 메시지의 마지막 날짜를 가져옵니다.
        let allChats = dmsRoom.chatMessages.sorted(byKeyPath: "createdAt", ascending: true)
        
        if let lastChat = allChats.last {
            lastDate = Calendar.current.startOfDay(for: lastChat.createdAt ?? Date())
        }
        
        for chat in models {
            if cancelUpdate.contains(chat.dmID) {
                continue
            }
            guard let user = try await upsertMembers(response: chat.user, ifRealm: realm) else {
                throw RealmError.failAdd
            }
            let newChat = try await upsertChat(chat, user: user, ifRealm: realm)
            
            chatModels.append(newChat)
        }
        
        try await realm.asyncWrite {
            for chatModel in chatModels {
                let chatDate = Calendar.current.startOfDay(for: chatModel.createdAt ?? Date())
                
                if lastDate != chatDate {
                    chatModel.isDateSection = true
                    lastDate = chatDate
                } else {
                    chatModel.isDateSection = false
                }
                
                realm.add(chatModel, update: .modified)
            }
            
            dmsRoom.chatMessages.append(objectsIn: chatModels)
        }
    }
}


extension RealmRepository {
    
    @discardableResult
    func upsertChat(_ model: WorkSpaceChatEntity, user: UserRealmModel, ifRealm: Realm? = nil) async throws -> ChatRealmModel {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        try await realm.asyncWrite {
            realm.create(ChatRealmModel.self, value: [
                "chatID": model.chatId,
                "channelID" : model.channelId,
                "content" : model.content as Any,
                "createdAt" : model.createdAt.toDate as Any,
                "user" : user.userID,
                "files" : model.files ?? []
            ], update: .modified)
        }
        let model = realm.object(ofType: ChatRealmModel.self, forPrimaryKey: model.chatId)
        
        guard let model else { throw RealmError.failAdd }
        
        return model
    }
    
    @discardableResult
    func upsertChat(
        _ model: DMSChatEntity,
        user: UserRealmModel,
        ifRealm: Realm? = nil
    ) async throws -> DMChatRealmModel {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        try await realm.asyncWrite {
            realm.create(DMChatRealmModel.self, value: [
                "dmID": model.dmID,
                "roomID" : model.roomID,
                "content" : model.content as Any,
                "createdAt" : model.createdAt.toDate as Any,
                "user" : user.userID,
                "files" : model.files ?? []
            ], update: .modified)
        }
        let model = realm.object(
            ofType: DMChatRealmModel.self,
            forPrimaryKey: model.dmID
        )
        
        guard let model else { throw RealmError.failAdd }
        
        return model
    }
    
}
extension RealmRepository {
    func toChat(_ models: [ChatRealmModel], userID: String)  async throws -> [ChatModeEntity] {
        
        var wait = [ChatModeEntity] ()
        for model in models {
            let result = try await toChat(model, userID: userID)
            if let result {
                wait.append(result)
            }
        }
        return wait
    }
    
    func toChat(_ model: ChatRealmModel, userID: String, ifRealm: Realm? = nil)  async throws -> ChatModeEntity? {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        guard let user = realm.object(
            ofType: UserRealmModel.self,
            forPrimaryKey: model.user
        ) else { return nil }
        
//        guard let user = model.user else { return nil }
        
        let ifMe: Bool = model.user == userID
        
        let fakeModel = WorkSpaceMemberEntity(
            userID: user.userID,
            email: user.email,
            nickName: user.nickName,
            profileImage: user.profileImage
        )
        
        return ChatModeEntity(
            chatID: model.chatID,
            isMe: ifMe ? .me : .other(fakeModel),
            content: model.content ?? "",
            files: Array(model.files),
            date: model.createdAt ?? Date(),
            isFirstDate: model.isDateSection
        )
    }
    
    func toChat(_ models: [DMChatRealmModel], userID: String)  async throws -> [ChatModeEntity] {
        var wait = [ChatModeEntity] ()
        for model in models {
            let result = try await toChat(model, userID: userID)
            if let result {
                wait.append(result)
            }
        }
        return wait
    }
    
    func toChat(_ model: DMChatRealmModel, userID: String, ifRealm: Realm? = nil)  async throws -> ChatModeEntity? {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        guard let user = realm.object(
            ofType: UserRealmModel.self,
            forPrimaryKey: model.user
        ) else { return nil }
        
        let ifMe: Bool = model.user == userID
        
        let fakeModel = WorkSpaceMemberEntity(
            userID: user.userID,
            email: user.email,
            nickName: user.nickName,
            profileImage: user.profileImage
        )
        
        return ChatModeEntity(
            chatID: model.dmID,
            isMe: ifMe ? .me : .other(fakeModel),
            content: model.content ?? "",
            files: Array(model.files),
            date: model.createdAt ?? Date(),
            isFirstDate: model.isDateSection
        )
    }
}
extension RealmRepository {
    
    func workSpaceToChannel(_ workSpace: WorkSpaceRealmModel) async -> WorkSpaceChannelsEntity {
        
        let itemSetting = Array(workSpace.channels.sorted(by: \.createdAt))
        
        let item = itemSetting.compactMap { @MainActor model in
            
            return WorkSpaceChannelEntity(
                channelID: model.channelID,
                name: model.name,
                introduce: model.introduce,
                ownerID: model.ownerID,
                didNotReadCount: model.didNotReadCount
            )
        }
        
        let channel = WorkSpaceChannelsEntity(items: item)
        
        return channel
    }
    
    func userToMember(_ users: [UserRealmModel]) -> [WorkSpaceMembersEntity] {
        return users.map { @MainActor model in
            return userToMember(model)
        }
    }
    
    func userToMember(_ user: UserRealmModel) -> WorkSpaceMembersEntity {
        return WorkSpaceMembersEntity(
            userID: user.userID,
            email: user.email,
            nickname: user.nickName,
            profileImage: user.profileImage
        )
    }
    
}
extension RealmRepository {
    
    func removeChannel(_ channelID: String,_ ifRealm: Realm? = nil) async throws {
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        guard let channel = realm.object(ofType: WorkSpaceChannelRealmModel.self, forPrimaryKey: channelID) else {
            throw RealmError.cantFindModel
        }
        
        try await realm.asyncWrite {
            realm.delete(channel.chatMessages)
            realm.delete(channel)
        }
    }
}

extension RealmRepository {
    
    @MainActor
    @discardableResult
    func upsertDMSRoomEntity(_ models: [DMSRoomEntity], workSpaceID: String,_ ifRealm: Realm? = nil) async throws -> [DMSRoomRealmModel] {
        
        var realm: Realm
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        var results: [DMSRoomRealmModel] = []
        for model in models {
            let result = try await upsertDMSRoomEntity(model, workSpaceID: workSpaceID, realm)
            results.append(result)
        }
        return results
    }
    
    @MainActor
    @discardableResult
    func upsertDMSRoomEntity(_ model: DMSRoomEntity, workSpaceID: String,_ ifRealm: Realm? = nil ) async throws -> DMSRoomRealmModel {
        var realm: Realm
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        try await realm.asyncWrite {
            realm.create(DMSRoomRealmModel.self, value: [
                "roomId": model.roomId,
                "workSpaceID": workSpaceID,
                "userID" : model.user.userID,
                "email" : model.user.email,
                "nickName" : model.user.nickname,
                "profileImage" : model.user.profileImage
            ], update: .modified)
        }
        let model = realm.object(ofType: DMSRoomRealmModel.self, forPrimaryKey: model.roomId)
        
        guard let model else { throw RealmError.failAdd }
        
        return model
    }
}

extension RealmRepository: DependencyKey {
    static var liveValue: RealmRepository = Self()
}

extension DependencyValues {
    var realmRepository: RealmRepository {
        get { self[RealmRepository.self] }
        set { self[RealmRepository.self] = newValue }
    }
}
