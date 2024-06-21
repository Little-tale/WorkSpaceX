//
//  WorkSpaceChannelLiistView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import SwiftUI
import ComposableArchitecture


struct WorkSpaceChannelListView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceChannelListFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.xImage
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .asButton {
                            store.send(.dismissTapped)
                        }
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}
