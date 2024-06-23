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
        GeometryReader { geometry in
            HStack {
                switch model.isMe {
                case .me:
                    Spacer()
                    modelCaseView()
                        .frame(maxWidth: geometry.size.width / 1.8, alignment: .trailing)
                        .padding(.trailing, 10)
                case .other(let string):
                    modelCaseView()
                        .frame(maxWidth: geometry.size.width / 1.8, alignment: .leading)
                        .padding(.leading, 10)
                    Spacer()
                }
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
}

extension ChatModeView {
    private func textModeView() -> some View {
        Text(model.content)
            .modifier(ChatModifier(isMe: true))
            .font(WSXFont.title2)
    }
}


#Preview {
    ChatModeView(model: .init(chatID: "testID", isMe: .other("test") ,chatMode: .text, content: "테스트 안녕하세요!!!!ㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇㅁㄴㅇ", files: []))
}
