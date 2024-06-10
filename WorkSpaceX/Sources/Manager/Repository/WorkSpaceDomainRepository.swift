//
//  WorkSpaceDomainRepository.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation
import ComposableArchitecture

struct WorkSpaceDomainRepository {
    
}

extension WorkSpaceDomainRepository: DependencyKey {
    static var liveValue: Self = Self ()

}

extension DependencyValues {
    var workspaceDomainRepository: WorkSpaceDomainRepository {
        get { self[WorkSpaceDomainRepository.self] }
        set { self[WorkSpaceDomainRepository.self] = newValue }
    }
}
