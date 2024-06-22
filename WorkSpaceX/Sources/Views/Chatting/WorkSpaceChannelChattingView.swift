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
            .onAppear {
                store.send(.onAppear)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.back
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(WSXColor.black)
                        .asButton {
                            store.send(.popClicked)
                        }
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        WSXImage.shapBold
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(WSXColor.black)
                        
                        Text(store.navigationTitle)
                            .font(WSXFont.title1)
                        
                        Text(store.navigationMemberCount)
                            .font(WSXFont.regu1)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
