//
//  ExScreens.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/15/24.
//

import Foundation

extension SideMenuCoordinator.SideMenuScreen.State: Identifiable {
    var id: UUID {
        switch self {
        case let .base(state):
            return state.id
        }
    }
}
