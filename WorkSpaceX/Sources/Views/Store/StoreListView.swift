//
//  StoreListView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import SwiftUI
import ComposableArchitecture

struct StoreListView: View {
    
    @Perception.Bindable var store: StoreOf<StoreListFeature>
    
    var body: some View {
        WithPerceptionTracking {
            
        }
    }
}
