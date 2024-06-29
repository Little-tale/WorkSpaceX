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
            
            VStack {
                
            }
            .navigationTitle("채널 관리자 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .bottomBar)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.xImage
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(WSXColor.black)
                        .asButton {
                            store.send(.backButtonTapped)
                        }
                }
            }
        }
    }
}
