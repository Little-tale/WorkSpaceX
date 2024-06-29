//
//  ChannelOwnerChangeView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/29/24.
//

import SwiftUI
import ComposableArchitecture

struct ChannelOwnerChangeView: View {
    
    @Perception.Bindable var store: StoreOf<ChannelOwnerChangeFeature>
    
    var body: some View {
        WithPerceptionTracking {
            
        }
    }
}
