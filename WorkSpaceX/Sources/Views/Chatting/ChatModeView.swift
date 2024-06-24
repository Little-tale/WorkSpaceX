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
        WithPerceptionTracking {
            HStack(alignment: .top) {
                switch store.model.isMe {
                case .me:
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(DateManager.shared.dateToStringToChat(store.model.date, isMe: true))
                            .font(WSXFont.caption)
                            .padding(.leading, 15)
                        modelCaseView()
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
                                .modifier(ChatModifier(isMe: false))
                    
                            Text(DateManager.shared.dateToStringToChat(store.model.date, isMe: false))
                                .font(WSXFont.caption)
                                .padding(.trailing, 15)
                        }
                    }
                    Spacer()
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
    @ViewBuilder
    private func modelCaseView() -> some View {
        switch store.model.chatMode {
        case .text:
            textModeView()
        case .File:
            fileCountCaseView(with: .five)
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
        .asButton {
            store.send(.profileClicked)
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
    
    
    @ViewBuilder
    private func imageForFileType(_ fileType: ChatModeFeature.FileType, model: String) -> some View {
        switch fileType {
        case .unknown:
            Image(systemName: "questionmark")
        case .image:
            DownSamplingImageView(url: URL(string: model), size: CGSize(width: 60, height: 60))
        case .PDF:
             Image(systemName: "doc.richtext")
        case .ZIP:
             Image(systemName: "doc.zipper")
        }
    }
    
    @ViewBuilder
    private func fileCountCaseView(with caseOF: ChatModeFeature.FileCountCase) -> some View {
        switch caseOF {
        case .none:
            EmptyView()
        case .one:
            Text("???")
                .frame(width: 100, height: 100)
                .background(WSXColor.errorRed)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        case .two:
            HStack {
                Text("???")
                    .frame(width: 80, height: 80)
                    .background(WSXColor.errorRed)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("???")
                    .frame(width: 80, height: 80)
                    .background(WSXColor.errorRed)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        case .three:
            VStack (alignment: .center) {
                HStack {
                    Text("???")
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("???")
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Text("???")
                    .frame(width: 80, height: 80)
                    .background(WSXColor.errorRed)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
        case .four:
            VStack (alignment: .center) {
                HStack {
                    Text("???")
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("???")
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                HStack {
                    Text("???")
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("???")
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        case .five:
            VStack (alignment: .center) {
                HStack {
                    Text("???")
                        .frame(width: 60, height: 60)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("???")
                        .frame(width: 60, height: 60)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("???")
                        .frame(width: 60, height: 60)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                HStack {
                    Text("???")
                        .frame(width: 80, height: 70)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("???")
                        .frame(width: 80, height: 70)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
            }
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
            content: "ㅁㄴㅇㅁㅇㅁㄴㅇㅁㅇㅁㄴㅇㅁㄴㅇㅁㅇㄴㅁㄴㅇㅁㄴㅇㄴㅁㅇㅁㅇㅁㄴㄴㅇㅁㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㅇ",
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
