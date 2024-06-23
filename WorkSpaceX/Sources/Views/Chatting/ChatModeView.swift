//
//  ChatModeVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import SwiftUI
import ComposableArchitecture

struct ChatModeView: View {

    @Perception.Bindable var store: StoreOf<ChatModeFeature>
    
    var body: some View {
            HStack(alignment: .top) {
                switch store.model.isMe {
                case .me:
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(DateManager.shared.dateToStringToChat(store.model.date, isMe: true))
                            .font(WSXFont.caption)
                            
                        modelCaseView()
                            .frame(maxWidth: UIScreen.main.bounds.width / 2)
                            .modifier(ChatModifier(isMe: true))
                            .padding(.trailing, 10)
                            
                    }
                case .other(let member):
                    otherProfileView(model: member)
                        .padding(.leading, 10)

                    VStack (alignment: .leading) {
                        Text(member.nickName)
                            .font(WSXFont.regu1)
                        HStack(alignment:.bottom) {
                            modelCaseView()
                                .frame(maxWidth: UIScreen.main.bounds.width / 2)
                                .modifier(ChatModifier(isMe: false))
                            Text(DateManager.shared.dateToStringToChat(store.model.date, isMe: false))
                                .font(WSXFont.caption)
                        }
                    }
                    Spacer()
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
    }
    
    @ViewBuilder
    private func modelCaseView() -> some View {
        switch store.model.chatMode {
        case .text:
            textModeView()
        case .File:
            EmptyView()
        case .textAndFile:
            EmptyView()
        }
    }
    
    private func otherProfileView(model: WorkSpaceMemberEntity) -> some View {
        HStack {
            if let image = model.profileImage {
                DownSamplingImageView(url: URL(string: image), size: CGSize(width: 40, height: 40))
                    .frame(width: 40 , height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                WSXImage.profileEmpty1
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

extension ChatModeView {
    private func textModeView() -> some View {
        Text(store.model.content)
            .font(WSXFont.title2)
    }
}
extension ChatModeView {
    private func FileModeView() -> some View {
        VStack {
            
        }
    }
}

#Preview {
    ChatModeView(store: Store(
        initialState: ChatModeFeature.State(model: .init(
            chatID: "asd",
            isMe: .other(.init(
                userID: "TestID",
                email: "이메일",
                nickName: "라일리",
                profileImage: nil)
            ),
            chatMode: .File,
            content: "",
            files: [],
            date: Date())
        ),
        reducer: {
            ChatModeFeature()
        })
    )
}

/*
 .other(.init(
     userID: "TestID",
     email: "이메일",
     nickName: "라일리",
     profileImage: nil)
 )
 */
