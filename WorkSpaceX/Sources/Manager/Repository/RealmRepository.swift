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
    func upsertToWorkSpaceChannelAppend(workSpaceID: String, chanel: ChanelEntity) async throws {
        
        let realm = try await Realm(actor: MainActor.shared)
        
        guard let channelModel = try await upserWorkSpaceChannel(channel: chanel, ifRealm: realm)
        else {
            throw RealmError.failAdd
        }
        
        // 기존 워크스페이스 모델 가져오기
        guard let workSpaceModel = realm.object(ofType: WorkSpaceRealmModel.self, forPrimaryKey: workSpaceID) else {
            throw RealmError.cantFindModel
        }
        
        try await realm.asyncWrite {
            var update = Array(workSpaceModel.channels)
            update.append(channelModel)
            realm.create(
                WorkSpaceRealmModel.self,
                value: [
                    "workSpaceID" : workSpaceID,
                    "channels": update
                ],
                update: .modified)
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
        
        try await realm.asyncWrite { // 서버에 없는것 부터 제거
            
            let currentIDs = Set(realm.objects(WorkSpaceChannelRealmModel.self).map{ $0.channelID })
            
            let serverIDs = channels.map { $0.channelId }
            
            let idsToDelete = currentIDs.subtracting(serverIDs)
            
            let objectsToDelete = realm.objects(WorkSpaceChannelRealmModel.self).filter("channelID IN %@", idsToDelete)
            
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


extension RealmRepository: DependencyKey {
    static var liveValue: RealmRepository = Self()
}

extension DependencyValues {
    var realmRepository: RealmRepository {
        get { self[RealmRepository.self] }
        set { self[RealmRepository.self] = newValue }
    }
}
