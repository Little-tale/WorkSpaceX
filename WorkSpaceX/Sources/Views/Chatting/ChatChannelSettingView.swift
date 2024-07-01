//
//  ChatChannelSettingView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/26/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView
/*
 1. 채널에서 나가기 구현 0
 2. 채널에서 관리자 변경 구현 0
 3. 채널 편집 뷰 구현 0
 4. 다른 사용자 프로필 화면 구현
 */

struct ChatChannelSettingView: View {
    
    @Perception.Bindable var store: StoreOf<ChatChannelSettingFeature>
    
    @State 
    var memberToggle: Bool = false
    
    /// TCA Router ISSUE 로 인한 방책
    @State
    var alertCaseOf: ChatChannelSettingFeature.State.AlertCase? = nil
    @State
    var alertTrigger: Bool = false
    
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
            .bind($store.alertCaseOf.sending(\.alertCaseOf), to: $alertCaseOf)
            .onChange(of: alertCaseOf) { _ in
                withAnimation {
                    if alertCaseOf != nil {
                        alertTrigger = true
                    } else {
                        alertTrigger = false
                    }
                }
            }
            .onChange(of: alertCaseOf) { newValue in
                print("뷰 얼렛 케이스 발동")
                guard let newValue else { return }
                CustomAlertWindow.shared.show {
                    CustomAlertView(
                        alertMode: newValue.alertMode,
                        isShowing: $alertTrigger,
                        title: newValue.title,
                        message: newValue.message,
                        onCancel: {
                            store.send(.alertCaseOf(nil))
                        }, onAction: {
                            store.send(.alertAction(newValue))
                            store.send(.alertCaseOf(nil))
                        }, actionTitle: newValue.alertActionTitle)
                }
            }
            .popup(isPresented: $store.channelOwnerChanged.sending(\.channelOwnerChanged)) {
                PopUpViewSmall(text: "채널 관리자가 변경되었습니다.")
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .autohideIn(2)
            }
            .navigationTitle("채널 설정")
            .toolbar(.hidden, for: .bottomBar)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
    private func customBinding() -> Binding<Bool> {
        return Binding(
            get: {alertCaseOf != nil},
            set: { new in
                if !new {
                    store.send(.alertCaseOf(nil))
                }
            }
        )
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
                        store.send(.channelExitTry)
                    })
            }
        }
    }
    
    private func deleteChannelButtonView() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널 삭제")
                    .modifier(NormalButtonViewModifier(colorSetting: .red) {
                        store.send(.channelDeleteClicked)
                    })
            }
        }
    }
    
    private func changeOwnerButton() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널 관리자 변경")
                    .modifier(NormalButtonViewModifier(colorSetting: .def) {
                        store.send(.channelOwnerChangeRequest)
                    })
            }
        }
    }
    
    private func channelEditButton() -> some View {
        WithPerceptionTracking {
            VStack {
                Text("채널 편집")
                    .modifier(NormalButtonViewModifier(colorSetting: .custom(WSXColor.lightGreen)) {
                        store.send(.channelEditClicked)
                    })
            }
        }
    }
    
}
