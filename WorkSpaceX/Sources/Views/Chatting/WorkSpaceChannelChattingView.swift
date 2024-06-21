//
//  WorkSpaceChannelChattingView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceChannelChattingView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceChannelChattingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("채팅뷰 탸다~")
            }
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
