//
//  RealmReader.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/17/24.
//

import Foundation
import RealmSwift
import ComposableArchitecture

struct WorkSpaceReader {
    
    static let shared = WorkSpaceReader()
    
    @MainActor
    func observeChanges<M: Object>(
        for modelType: M.Type,
        sorted keyPath: String? = nil,
        ascending: Bool = true
    ) -> AsyncStream<[M]> {
        
        return AsyncStream { continuation in
            Task {
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    
                    var results = realm.objects(modelType)
                    if let keyPath = keyPath {
                        results = results.sorted(byKeyPath: keyPath, ascending: ascending)
                    }
                    
                    let token = results.observe { changes in
                        Task { @MainActor in
                            switch changes {
                            case .initial(let collection):
                                continuation.yield(Array(collection))
                            case .update(let collection, _, _, _):
                                continuation.yield(Array(collection))
                            case .error(let error):
                                print(error)
                                continuation.finish()
                            }
                        }
                    }
                    
                    continuation.onTermination = { @Sendable _ in
                        token.invalidate()
                    }
                } catch {
                    print("\(error)")
                    continuation.finish()
                }
            }
        }
    }
    
    @MainActor
    func observeChangeForPrimery<M: Object> (
        for modelType: M.Type,
        primary key: String
    ) -> AsyncStream<M?> {
        return AsyncStream { continu in
            Task {
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    guard let object = realm.object(ofType: M.self, forPrimaryKey: key) else {
                        continu.yield(nil)
                        continu.finish()
                        return
                    }
                    
                    let token = object.observe { changes in
                        Task { @MainActor in
                            switch changes {
                            case .error:
                                print("observeChangeForPrimery ERROR")
                                continu.yield(nil)
                                continu.finish()
                                
                            case let .change(model, _):
                                
                                guard let ob = model as? M else {
                                    continu.yield(nil)
                                    continu.finish()
                                    return
                                }
                                continu.yield(ob)
                                
                            case .deleted:
                                continu.yield(nil)
                                continu.finish()
                            }
                        }
                    }
                    continu.onTermination = { @Sendable _ in
                        token.invalidate()
                    }
                } catch {
                    print(error)
                    continu.finish()
                }
            }
        }
    }
}

extension WorkSpaceReader {
    
    func observeChaeelsForWorkSpace(
        workSpaceId: String,
        sort keyPath: String = "createdAt",
        ascending: Bool = true
    ) -> AsyncStream<[WorkSpaceChannelRealmModel]> {
        return AsyncStream { contin in
            Task {
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    guard let workSpace = realm.object(ofType: WorkSpaceRealmModel.self, forPrimaryKey: workSpaceId) else {
                        print("못참음")
                        contin.finish()
                        return
                    }
                    let channels = workSpace.channels.sorted(byKeyPath: keyPath, ascending: ascending)
                    
                    let token = channels.observe { changes in
                        Task { @MainActor in
                            switch changes {
                            case .initial(let collection):
                                contin.yield(Array(collection))
                            case .update(let collection, _, _, _):
                                contin.yield(Array(collection))
                            case .error(let error):
                                print(error)
                                contin.finish()
                            }
                        }                    }
                }
            }
        }
    }
    
    /// 해당 메서드는 업데이트 만을 방출합니다.
    func observeNewMessage(channelID: String) -> AsyncStream<ChatRealmModel> {
        
        return AsyncStream { contin in
            Task {
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    
                    guard let channel = realm.object(ofType: WorkSpaceChannelRealmModel.self, forPrimaryKey: channelID) else {
                        contin.finish()
                        return
                    }
                    
                    let tokken = channel.chatMessages.observe { change in
                        Task { @MainActor in
                            switch change {
                            case .initial(_):
                                break
                            case .update(let models, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                                for index in insertions {
                                    let new = models[index]
                                    contin.yield(new)
                                }
                            case .error(_):
                                contin.finish()
                            }
                        }
                    }
                    
                    contin.onTermination = { @Sendable _ in
                        tokken.invalidate()
                    }
                } catch {
                    contin.finish()
                }
            }
        }
    }
    
}

extension WorkSpaceReader: DependencyKey {
    static var liveValue: WorkSpaceReader = Self.shared
}
extension DependencyValues {
    var workSpaceReader: WorkSpaceReader {
        get { self[WorkSpaceReader.self] }
        set { self[WorkSpaceReader.self] = newValue }
    }
}


