//
//  WorkSpaceListScreens.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum WorkSpaceListScreens {
    case first(WorkSpaceListFeature)
}
