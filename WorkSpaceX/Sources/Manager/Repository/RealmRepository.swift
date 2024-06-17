//
//  RealmRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation
import RealmSwift
import ComposableArchitecture

//protocol RealmRepositoryType {
//    func fetchAll<M: Object>(type modelType: M.Type) -> Result<Results<M>,RealmError>
//
//    @discardableResult
//    func add<M:Object>(_ model: M) -> Result<M,RealmError>
//
//    func remove(_ model: Object) -> Result<Void,RealmError>
//}


struct RealmRepository {
    
    // private let realm: Realm?
    
    // private let asnycRealm: Realm?
    
    //    func fetchAll<M>(type modelType: M.Type) -> Result<RealmSwift.Results<M>, RealmError> where M : Object {
    //        guard let realm else { return .failure(.cantLoadRealm)}
    //
    //        return .success(realm.objects(modelType))
    //    }
    //
    //    func add<M>(_ model: M) -> Result<M, RealmError> where M : Object {
    //        guard let realm else { return .failure(.cantLoadRealm)}
    //        do {
    //            try realm.write {
    //                realm.add(model)
    //
    //            }
    //            return .success(model)
    //        } catch {
    //            return .failure(.failAdd)
    //        }
    //    }
    
    
    //    func remove(_ model: RealmSwift.Object) -> Result<Void, RealmError> {
    //        guard let realm else { return .failure(.cantLoadRealm)}
    //
    //        do {
    //            try realm.write {
    //
    //                realm.delete(model)
    //
    //            }
    //            return .success(())
    //        } catch {
    //            return .failure(.failRemove)
    //        }
    //
    //    }
    
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
    
    init() {
        //        do {
        //            let realms = try Realm()
        //            realm = realms
        //            print(realm?.configuration.fileURL ?? "Realm MISS")
        //        } catch {
        //            print("렘 자체 문제 ")
        //            realm = nil
        //        }
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
    func syncWorkSpaces(with responses: [WorkSpaceEntity]) async throws {
        let realm = try await Realm(actor: MainActor.shared)
        
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
}
//
//    func upsertWorkSpace(response: WorkSpaceEntity, with realm: Realm) {
//        print("워크 스페이스 저장중 ....")
//        do {
//            try realm.write{
//                realm.create(WorkSpaceRealmModel.self, value: [
//                    "workSpaceID" : response.workSpaceID,
//                    "workSpaceName" : response.name,
//                    "introduce" : response.description as Any,
//                    "coverImage" : response.coverImage?.absoluteString as Any,
//                    "ownerID" : response.ownerID,
//                    "createdAt" : response.createdAt.toDate as Any
//                ], update: .modified)
//            }
//        } catch {
//            print(error)
//        }
//    }



extension RealmRepository {
    
    //    @MainActor
    //    func observeChanges<M>(
    //
    //        for modelType: M.Type,
    //        sorted keyPath: String? = nil,
    //        ascending: Bool = true
    //
    //    ) -> AsyncStream<[M]> where M: Object {
    //
    //        return AsyncStream { continuation in
    //            print(":::::")
    //            guard let realm = try? Realm() else {
    //                continuation.finish()
    //                return
    //            }
    //
    //            var results = realm.objects(modelType)
    //
    //            if let keyPath = keyPath {
    //                results = results.sorted(byKeyPath: keyPath, ascending: ascending)
    //            }
    //
    //            let token = results.observe(on: .main) { changes in
    //                switch changes {
    //                case .initial(let results):
    //                    continuation.yield(Array(results))
    //
    //                case .update(let results, _, _, _):
    //                    continuation.yield(Array(results))
    //
    //                case .error(let error):
    //                    print(error)
    //                    continuation.yield([])
    //                }
    //            }
    //
    //            continuation.onTermination = { _ in
    //                token.invalidate()
    //            }
    //        }
    //    }
    
    
    
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
