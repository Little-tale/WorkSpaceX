//
//  WorkSpaceListCoordinatorView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct WorkSpaceListCoordinatorView: View {
    
    @State var store: StoreOf<WorkSpaceListCordinator>
    
    var body: some View {
        WithPerceptionTracking {
            //        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            //            switch screen.case {
            //            case let .home(store):
            //                WorkSpaceListView(store: store)
            //            }
            //        }
        }
    }
}

