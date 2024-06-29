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
                List {
                    ForEach(store.users, id: \.userID) { model in
                        userInfoView(model)
                            .asButton {
                                store.send(.selectedUser(model))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundStyle(WSXColor.black)
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationTitle("채널 관리자 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .bottomBar)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.xImage
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(WSXColor.black)
                        .asButton {
                            store.send(.backButtonTapped)
                        }
                }
            }
        }
    }
}

extension ChannelOwnerChangeView {
    
    private func userInfoView(_ model: WorkSpaceMembersEntity) -> some View {
        HStack {
            Group {
                if let userImage = model.profileImage {
                    DownSamplingImageView(url: URL(string: userImage), size: CGSize(width: 50, height: 50))
                } else {
                    WSXImage.profileEmpty1
                        .resizable()
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            
            VStack (alignment: .leading) {
                Text(model.nickname)
                    .font(WSXFont.title2)
                Text(model.email)
                    .font(WSXFont.caption)
            }
        }
    }
    
}
