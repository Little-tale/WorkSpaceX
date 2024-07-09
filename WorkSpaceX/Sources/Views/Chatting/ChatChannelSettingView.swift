//
//  ChatChannelSettingView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/26/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ChatChannelSettingView: View {
    
    @Perception.Bindable var store: StoreOf<ChatChannelSettingFeature>
    
    @State 
    var memberToggle: Bool = false
    
    /// TCA Router ISSUE 로 인한 방책
    @State
    var alertCaseOf: ChatChannelSettingFeature.State.AlertCase? = nil
    @State
    var alertTrigger: Bool = false
    // 팝업뷰 이슈로 인한 트리거
    @State
    private var showTemporaryPopup = false
    
    var rows: [GridItem] = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
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
                    
                    if showTemporaryPopup {
                        PopUpViewSmall(text: "채널 관리자가 변경되었습니다.")
                            .zIndex(1)
                    }
                }
                .navigationTitle("채널 설정")
                .toolbar(.hidden, for: .tabBar)
                .onAppear {
                    store.send(.onAppear)
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
                            ifMessageCenter: false,
                            onCancel: {
                                store.send(.alertCaseOf(nil))
                            }, onAction: {
                                store.send(.alertAction(newValue))
                                store.send(.alertCaseOf(nil))
                            }, actionTitle: newValue.alertActionTitle)
                    }
                }
                .onChange(of: store.channelOwnerChanged) { newValue in
                    if newValue {
                        withAnimation {
                            showTemporaryPopup = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showTemporaryPopup = false
                            }
                            store.send(.channelOwnerChanged(false))
                        }
                    }
                }
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
        HStack {
            Text(store.channelName)
                .font(WSXFont.title1)
                .foregroundStyle(WSXColor.black)
                .padding(.leading, 6)
            
            Spacer()
        }
    }
    
    private func channelIntroView() -> some View {
        HStack {
            Text(store.channelIntro)
                .font(WSXFont.title2)
                .foregroundStyle(WSXColor.black)
                .padding(.leading, 6)
            Spacer()
        }
    }
}

extension ChatChannelSettingView {
    
    private func memberExtensionView() -> some View {
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
    
    private func memberHeaderView() -> some View {
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
    
    private func memberContentView() -> some View {
        LazyVGrid(columns: rows) {
            ForEach(Array(store.users.enumerated()), id:\.element.userID) { index, user in
                memberView(with: user)
            }
        }
    }
    
    private func memberView(
        with member: WorkSpaceMembersEntity
    ) -> some View {
        
        VStack(alignment: .center) {
            if let imageString = member.profileImage {
                DownSamplingImageView(url: URL(string: imageString), size: ImageResizingCase.middel.size
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

extension ChatChannelSettingView {
    @ViewBuilder
    private func buttonSetView(isOwner: Bool) -> some View {
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
    
    private func outOfChannelButtonView() -> some View {
        VStack {
            Text("채널에서 나가기")
                .modifier(NormalButtonViewModifier(colorSetting: .red) {
                    store.send(.channelExitTry)
                })
        }
    }
    
    private func deleteChannelButtonView() -> some View {
        
        VStack {
            Text("채널 삭제")
                .modifier(NormalButtonViewModifier(colorSetting: .red) {
                    store.send(.channelDeleteClicked)
                })
        }
        
    }
    
    private func changeOwnerButton() -> some View {
        VStack {
            Text("채널 관리자 변경")
                .modifier(NormalButtonViewModifier(colorSetting: .def) {
                    store.send(.channelOwnerChangeRequest)
                })
        }
    }
    
    private func channelEditButton() -> some View {
        VStack {
            Text("채널 편집")
                .modifier(NormalButtonViewModifier(colorSetting: .custom(WSXColor.lightGreen)) {
                    store.send(.channelEditClicked)
                })
        }
    }
    
}
