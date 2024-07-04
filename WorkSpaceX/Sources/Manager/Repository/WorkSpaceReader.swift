//
//  RealmReader.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/17/24.
//

import Foundation
import RealmSwift
import ComposableArchitecture

class WorkSpaceReader {
    
    static let shared = WorkSpaceReader()
    
    private var tokens: [String: NotificationToken] = [:]
    
    private var dmListTokenID = "DMLISTTOKEN"
    
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
            Task { @MainActor in
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
                        }
                    }
                    contin.onTermination = { @Sendable _ in
                        token.invalidate()
                    }
                } catch {
                    print(error)
                    contin.finish()
                }
            }
        }
    }
    
    /// 해당 메서드는 업데이트 만을 방출합니다.
    @MainActor
    func observeNewMessage(channelID: String) -> AsyncStream<[ChatRealmModel]> {
        return AsyncStream { continuation in
            Task { @MainActor in
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    
                    guard let channel = realm.object(ofType: WorkSpaceChannelRealmModel.self, forPrimaryKey: channelID) else {
                        continuation.finish()
                        return
                    }
                    
                    let token = channel.chatMessages.observe { change in
                        Task { @MainActor in
                            switch change {
                            case .initial:
                                break
//                                continuation.yield(Array(models))
                            case .update(let models, deletions: _, insertions: let insertAt, modifications: _):
                                let new = insertAt.map { models[$0] }
                                
                                continuation.yield(Array(new))
                            case .error(_):
                                continuation.finish()
                            }
                        }
                    }
                    
                    tokens[channelID] = token
                    
                    continuation.onTermination = { @Sendable [weak self] _ in
                        token.invalidate()
                        self?.tokens[channelID] = nil
                    }
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    func observeChannelStop(_ channelID: String) async {
        tokens[channelID]?.invalidate()
        tokens[channelID] = nil
    }
    
}
extension WorkSpaceReader {
    
    @MainActor
    func observerToDMSRoom(workSpaceID: String) -> AsyncStream<[DMSRoomRealmModel]> {
        return AsyncStream { continuation in
            Task { @MainActor in
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                  
                    let dmsRoom = realm.objects(DMSRoomRealmModel.self).where({ $0.workSpaceID == workSpaceID })
                    
                    let token = dmsRoom.observe { change in
                        Task { @MainActor in
                            switch change {
                            case .initial(let models):
                                continuation.yield(Array(models))
                            case .update(let models, _, _, _):
                                
                                continuation.yield(Array(models))
                            case .error(_):
                                continuation.finish()
                            }
                        }
                    }
                    
                    tokens[dmListTokenID] = token
                    
                    continuation.onTermination = { @Sendable [weak self] _ in
                        guard let self else {
                            token.invalidate()
                            return
                        }
                        token.invalidate()
                        self.tokens[dmListTokenID] = nil
                    }
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    func stopToDMSRoom() {
        tokens[dmListTokenID]?.invalidate()
        tokens[dmListTokenID] = nil
    }
    
    @MainActor
    func observeNewMessage(dmRoomID: String) -> AsyncStream<[DMChatRealmModel]> {
        return AsyncStream { continuation in
            Task { @MainActor in
                do {
                    let realm = try await Realm(actor: MainActor.shared)
                    
                    guard let dmRoom = realm.object(ofType: DMSRoomRealmModel.self, forPrimaryKey: dmRoomID) else {
                        continuation.finish()
                        return
                    }
                    
                    let token = dmRoom.chatMessages.observe { change in
                        Task { @MainActor in
                            switch change {
                            case .initial:
                                break
                            case .update(let models, deletions: _, insertions: let insertAt, modifications: _):
                                
                                let new = insertAt.map { models[$0] }
        
                                continuation.yield(Array(new))
                            case .error(_):
                                continuation.finish()
                            }
                        }
                    }
                    
                    tokens[dmRoomID] = token
                    
                    continuation.onTermination = { @Sendable [weak self] _ in
                        token.invalidate()
                        self?.tokens[dmRoomID] = nil
                    }
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    func observeDMSStop(_ dmRoomID: String) {
        tokens[dmRoomID]?.invalidate()
        tokens[dmRoomID] = nil
    }
    
}

extension WorkSpaceReader: DependencyKey {
    static var liveValue: WorkSpaceReader = WorkSpaceReader.shared
}
extension DependencyValues {
    var workSpaceReader: WorkSpaceReader {
        get { self[WorkSpaceReader.self] }
        set { self[WorkSpaceReader.self] = newValue }
    }
}


