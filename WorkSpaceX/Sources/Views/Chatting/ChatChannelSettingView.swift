//
//  ChatChannelSettingView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/26/24.
//

import SwiftUI
import ComposableArchitecture

struct ChatChannelSettingView: View {
    
    @Perception.Bindable var store: StoreOf<ChatChannelSettingFeature>
    
    @State 
    var memberToggle: Bool = false
    
    var rows: [GridItem] = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                WSXColor.lightGray
                    .ignoresSafeArea()
                VStack {
                    channelNameView()
                        .padding(.vertical, 10)
                    channelIntroView()
                        .padding(.bottom, 5)
                    memberExtensionView()
                    
                    Spacer()
                }
            }
            .navigationTitle("채널 설정")
            .toolbar(.hidden, for: .bottomBar)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension ChatChannelSettingView {
    
    private func channelNameView() -> some View {
        WithPerceptionTracking {
            HStack {
                Text(store.channelName)
                    .font(WSXFont.title1)
                    .foregroundStyle(WSXColor.black)
                    .padding(.leading, 6)
                
                Spacer()
            }
        }
    }
    
    private func channelIntroView() -> some View {
        WithPerceptionTracking {
            HStack {
                Text(store.channelIntro)
                    .font(WSXFont.title2)
                    .foregroundStyle(WSXColor.black)
                    .padding(.leading, 6)
                
                Spacer()
            }
        }
    }
}

extension ChatChannelSettingView {
    
    private func memberExtensionView() -> some View {
        WithPerceptionTracking {
            List {
                Section {
                    if memberToggle {
                        memberContentView()
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .padding(.top, 10)
                    }
                } header: {
                    memberHeaderView()
                }
                .listRowBackground(WSXColor.lightGray)
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .background {
                WSXColor.lightGray
            }
        }
    }
    
    private func memberHeaderView() -> some View {
        WithPerceptionTracking {
            HStack {
                Text("멤버")
                Text(store.usersCount)
                Spacer()
                Image(systemName: memberToggle ? "chevron.down" : "chevron.right")
                    .foregroundStyle(WSXColor.black)
                    .asButton {
                        withAnimation {
                            memberToggle.toggle()
                        }
                    }
            }
        }
    }
    
    private func memberContentView() -> some View {
        WithPerceptionTracking {
            LazyVGrid(columns: rows) {
                ForEach(Array(store.users.enumerated()), id:\.element.userID) { index, user in
                    memberView(with: user)
                }
            }
        }
    }
    
    private func memberView(
        with member: WorkSpaceMembersEntity
    ) -> some View {
        WithPerceptionTracking {
            VStack(alignment: .center) {
                if let imageString = member.profileImage {
                    DownSamplingImageView(url: URL(string: imageString), size: CGSize(width: 50, height: 50)
                    )
                    .frame(width: 40, height: 40)
                } else {
                    WSXImage.profileEmpty1
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Text(member.nickname)
                    .font(WSXFont.regu1)
                    .frame(maxWidth: 40)
                    .lineLimit(1)
                    .foregroundStyle(WSXColor.black)
            }
        }
    }
}
