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

extension WorkSpaceReader: DependencyKey {
    static var liveValue: WorkSpaceReader = Self.shared
}
extension DependencyValues {
    var workSpaceReader: WorkSpaceReader {
        get { self[WorkSpaceReader.self] }
        set { self[WorkSpaceReader.self] = newValue }
    }
}


