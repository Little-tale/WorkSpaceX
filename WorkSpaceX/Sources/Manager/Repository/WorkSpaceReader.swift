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
                                print("Error observing changes: \(error)")
                                continuation.finish()
                            }
                        }
                    }
                    
                    continuation.onTermination = { @Sendable _ in
                        token.invalidate()
                    }
                } catch {
                    print("Error initializing Realm: \(error)")
                    continuation.finish()
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


//    var realm: Realm
//    //    let serialQueue: DispatchQueue
//
//    init(){
//        //        serialQueue = DispatchQueue(label: "workSpace-Queue")
//        //        do {
//        //            var realm: Realm!
//        //            try serialQueue.sync {
//        //                realm = try Realm(configuration: .defaultConfiguration)
//        //            }
//        //            self.realm = realm
//        //        } catch {
//        //            print(error)
//        //            self.realm = try! Realm()
//        //        }
//        realm = try! Realm()
//    }

//    func observeChanges<M: Object>(for modelType: M.Type, sorted keyPath: String? = nil, ascending: Bool = true) -> AsyncStream<[M]> {
//
//        return AsyncStream { continuation in
//
//            var results: Results<M>
//            results = realm.objects(modelType)
//            if let keyPath = keyPath {
//                results = results.sorted(byKeyPath: keyPath, ascending: ascending)
//            }
//
//            let token = results.observe(on:.main) { changes in
//                switch changes {
//                case .initial(let results):
//                    continuation.yield(Array(results))
//
//                case .update(let results, _, _, _):
//                    continuation.yield(Array(results))
//
//                case .error(let error):
//                    print("Error observing changes: \(error)")
//                    continuation.finish()
//                }
//            }
//
//            continuation.onTermination = { @Sendable _ in
//                token.invalidate()
//            }
//
//        }
//    }

//    func observeChanges<M: Object>(
//        for modelType: M.Type,
//        sorted keyPath: String? = nil,
//        ascending: Bool = true,
//        onChanged: @escaping ([M]) -> Void
//    ) {
//        do {
//            var results = realm.objects(modelType)
//            if let keyPath {
//                results = results.sorted(byKeyPath: keyPath, ascending: ascending)
//            }
//
//            let token = results.observe(on: .main) { changes in
//                switch changes {
//                case .initial(let models):
//                    onChanged(Array(models))
//                case .update(let models, _, _, _):
//                    onChanged(Array(models))
//                case .error:
//                    onChanged([])
//                }
//            }
//        }
//    }
