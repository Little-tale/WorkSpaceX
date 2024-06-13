//
//  RealmRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation
import RealmSwift
import ComposableArchitecture

protocol RealmRepositoryType {
    func fetchAll<M: Object>(type modelType: M.Type) -> Result<Results<M>,RealmError>
    
    @discardableResult
    func add<M:Object>(_ model: M) -> Result<M,RealmError>
    
    func remove(_ model: Object) -> Result<Void,RealmError>
}


struct RealmRepository: RealmRepositoryType {
    
    private let realm: Realm?
    
    func fetchAll<M>(type modelType: M.Type) -> Result<RealmSwift.Results<M>, RealmError> where M : Object {
        guard let realm else { return .failure(.cantLoadRealm)}
        
        return .success(realm.objects(modelType))
    }
    
    func add<M>(_ model: M) -> Result<M, RealmError> where M : Object {
        guard let realm else { return .failure(.cantLoadRealm)}
        do {
            try realm.write {
                realm.add(model)
                
            }
            return .success(model)
        } catch {
            return .failure(.failAdd)
        }
    }
    
    func remove(_ model: RealmSwift.Object) -> Result<Void, RealmError> {
        guard let realm else { return .failure(.cantLoadRealm)}
        do {
            try realm.write {
                realm.delete(model)
            }
            return .success(())
        } catch {
            return .failure(.failRemove)
        }
    }
    
    
    
    
    init() {
        do {
            let realms = try Realm()
            realm = realms
            print(realm?.configuration.fileURL ?? "Realm MISS")
        } catch {
            print("렘 자체 문제 ")
            realm = nil
        }
    }
}


extension RealmRepository {
    
    func upsertUserModel(response: UserEntity) {
        print("유저 정보 저장중.....")
        do {
            try realm?.write{
                realm?.create(UserRealmModel.self, value: [
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
