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
                    buttonSetView(isOwner: store.isOwner)
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
            .frame(maxHeight: memberToggle ? .infinity : 60)
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

extension ChatChannelSettingView {
    
    private func buttonSetView(isOwner: Bool) -> some View {
        WithPerceptionTracking {
            if isOwner {
                VStack( spacing: 8 ) {
                    channelEditButton()
                    changeOwnerButton()
                    outOfChannelButtonView()
                    deleteChannelButtonView()
                }
            } else {
                outOfChannelButtonView()
            }
        }
    }
    
    private func outOfChannelButtonView() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널에서 나가기")
                    .modifier(NormalButtonViewModifier(colorSetting: .red) {
                        
                    })
            }
        }
    }
    
    private func deleteChannelButtonView() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널 삭제")
                    .modifier(NormalButtonViewModifier(colorSetting: .red) {
                        
                    })
            }
        }
    }
    
    private func changeOwnerButton() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널 관리자 변경")
                    .modifier(NormalButtonViewModifier(colorSetting: .def) {
                        
                    })
            }
        }
    }
    
    private func channelEditButton() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널 편집")
                    .modifier(NormalButtonViewModifier(colorSetting: .custom(WSXColor.lightGreen)) {
                        
                    })
            }
        }
    }
    
}
