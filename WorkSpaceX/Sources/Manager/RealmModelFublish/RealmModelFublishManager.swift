//
//  RealmModelFublishManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/16/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

struct RealmModelFublishManager {
    var observeWorkSpaceChanges: () -> AsyncStream<[WorkSpaceRealmModel]>
}

//extension RealmModelFublishManager: DependencyKey {
//    
//    static var liveValue: Self = Self(
//        observeWorkSpaceChanges: {}
//    )
//    
//}
