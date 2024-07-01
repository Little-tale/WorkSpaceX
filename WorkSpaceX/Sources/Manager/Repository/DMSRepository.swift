//
//  DMSRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

struct DMSRepository {
    
    func dmRoomListReqeust(_ workSpaceID: String) async throws -> Void {
        
    }
}

extension DMSRepository: DependencyKey {
    
    static var liveValue: Self = Self ()
    
}

extension DependencyValues {
    var dmsRepository: DMSRepository {
        get { self[DMSRepository.self] }
        set { self[DMSRepository.self] = newValue }
    }
}