//
//  ChatModeVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import SwiftUI

struct ChatModeView: View {

    let model: ChatModeEntity
    
    var body: some View {
            HStack(alignment: .top) {
                switch model.isMe {
                case .me:
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(DateManager.shared.dateToStringToChat(model.date, isMe: true))
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
                            Text(DateManager.shared.dateToStringToChat(model.date, isMe: false))
                                .font(WSXFont.caption)
                        }
                    }
                    Spacer()
                }
            }
    }
    
    @ViewBuilder
    private func modelCaseView() -> some View {
        switch model.chatMode {
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
        Text(model.content)
            .font(WSXFont.title2)
    }
}

    /*
     .other(.init(
         userID: "TestID",
         email: "이메일",
         nickName: "라일리",
         profileImage: nil)
     )
     */
#Preview {
    ChatModeView(model: .init(
        chatID: "testID",
        isMe: .other(.init(
            userID: "TestID",
            email: "이메일",
            nickName: "라일리",
            profileImage: nil)
        ),
        chatMode: .text,
        content: "테스트 안녕하세요!!!! 테스트입니다 테스트, 테스트입니다 테스트, 테스트입니다 테스트, 테스트입니다 테스트, 테스트입니다 테스트",
        files: [], date: Date())
    )
}
