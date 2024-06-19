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
        
        try await realm.asyncWrite{
            if let model = realm.object(ofType: type, forPrimaryKey: modelId) {
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
    func upsertUserModel(response: UserEntity) async throws{
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
        } catch {
            print(error)
            return
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
        
        try await realm.asyncWrite {
            let currentIDs = Set(realm.objects(WorkSpaceRealmModel.self).map{ $0.workSpaceID })
            let serverIDs = responses.map { $0.workSpaceID }
            
            let idsToDelete = currentIDs.subtracting(serverIDs)
            
            let objectsToDelete = realm.objects(WorkSpaceRealmModel.self).filter("workSpaceID IN %@", idsToDelete)
            
            realm.delete(objectsToDelete)
            
            responses.forEach { models in
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
    @discardableResult
    func upserWorkSpaceChannels(channels: [ChanelEntity], ifRealm: Realm? = nil) async throws -> [WorkSpaceChannelRealmModel] {
        
        var realm: Realm
        
        if let ifRealm {
            realm = ifRealm
        } else {
            realm = try await Realm(actor: MainActor.shared)
        }
        
        print("워크 스페이스 체널 저장중 ....")
        
        var results: [WorkSpaceChannelRealmModel] = []
        
        for entity in channels {
            try await realm.asyncWrite {
                realm.create(WorkSpaceChannelRealmModel.self, value: [
                    "channelID" : entity.channelId,
                    "workSpaceName" : entity.name,
                    "introduce" : entity.description as Any,
                    "coverImage" : entity.coverImage as Any,
                    "ownerID" : entity.owner_id,
                    "createdAt" : entity.createdAt.toDate as Any
                ], update: .modified)
            }
            if let addedModel = realm.object(ofType: WorkSpaceChannelRealmModel.self, forPrimaryKey: entity.channelId) {
                results.append(addedModel)
            }
        }
        return results
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
