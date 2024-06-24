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
        switch store.chatMode {
        case .text:
            textModeView()
        case .File:
            fileCountCaseView(with: store.fileCountCase)
        case .textAndFile:
            EmptyView()
        case .loading:
            ProgressView()
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
    private func fileModeView() -> some View {
        VStack {
            ForEach(Array(store.model.files.enumerated()), id: \.element) { index, file in
                if let fileType = store.fileModeModels[file] {
                    imageForFileType(fileType, model: file)
                }
            }
        }
    }
    
    @ViewBuilder
    private func imageForFileType(_ fileType: ChatModeFeature.FileType, model: String) -> some View {
        switch fileType {
        case .unknown:
            Image(systemName: "questionmark")
                .resizable()
        case .image:
            DownSamplingImageView(url: URL(string: model), size: CGSize(width: 60, height: 60))
        case .PDF:
            Image(systemName: "doc.richtext")
                .resizable()
        case .ZIP:
            Image(systemName: "doc.zipper")
                .resizable()
        }
    }
    
    @ViewBuilder
    private func fileCountCaseView(with caseOF: ChatModeFeature.FileCountCase) -> some View {
        switch caseOF {
        case .none:
            EmptyView()
        case .one:
            if let file = store.model.files.first, let fileType = store.fileModeModels[file] {
                imageForFileType(fileType, model: file)
                    .frame(width: 100, height: 100)
                    .background(WSXColor.errorRed)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .asButton {
                        store.send(.selectedFileURLString(file))
                    }
            }
        case .two:
            HStack {
                if let file1 = store.model.files[safe: 0], let fileType1 = store.fileModeModels[file1] {
                    imageForFileType(fileType1, model: file1)
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .asButton {
                            store.send(.selectedFileURLString(file1))
                        }
                }
                if let file2 = store.model.files[safe: 1], let fileType2 = store.fileModeModels[file2] {
                    imageForFileType(fileType2, model: file2)
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .asButton {
                            store.send(.selectedFileURLString(file2))
                        }
                }
            }
        case .three:
            VStack(alignment: .center) {
                HStack {
                    if let file1 = store.model.files[safe: 0], let fileType1 = store.fileModeModels[file1] {
                        imageForFileType(fileType1, model: file1)
                            .frame(width: 80, height: 80)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file1))
                            }
                    }
                    if let file2 = store.model.files[safe: 1], let fileType2 = store.fileModeModels[file2] {
                        imageForFileType(fileType2, model: file2)
                            .frame(width: 80, height: 80)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file2))
                            }
                    }
                }
                if let file3 = store.model.files[safe: 2], let fileType3 = store.fileModeModels[file3] {
                    imageForFileType(fileType3, model: file3)
                        .frame(width: 80, height: 80)
                        .background(WSXColor.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .asButton {
                            store.send(.selectedFileURLString(file3))
                        }
                }
            }
        case .four:
            VStack(alignment: .center) {
                HStack {
                    if let file1 = store.model.files[safe: 0], let fileType1 = store.fileModeModels[file1] {
                        imageForFileType(fileType1, model: file1)
                            .frame(width: 80, height: 80)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file1))
                            }
                    }
                    if let file2 = store.model.files[safe: 1], let fileType2 = store.fileModeModels[file2] {
                        imageForFileType(fileType2, model: file2)
                            .frame(width: 80, height: 80)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file2))
                            }
                    }
                }
                HStack {
                    if let file3 = store.model.files[safe: 2], let fileType3 = store.fileModeModels[file3] {
                        imageForFileType(fileType3, model: file3)
                            .frame(width: 80, height: 80)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file3))
                            }
                    }
                    if let file4 = store.model.files[safe: 3], let fileType4 = store.fileModeModels[file4] {
                        imageForFileType(fileType4, model: file4)
                            .frame(width: 80, height: 80)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file4))
                            }
                    }
                }
            }
        case .five:
            VStack(alignment: .center) {
                HStack {
                    if let file1 = store.model.files[safe: 0], let fileType1 = store.fileModeModels[file1] {
                        imageForFileType(fileType1, model: file1)
                            .frame(width: 60, height: 60)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file1))
                            }
                    }
                    if let file2 = store.model.files[safe: 1], let fileType2 = store.fileModeModels[file2] {
                        imageForFileType(fileType2, model: file2)
                            .frame(width: 60, height: 60)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file2))
                            }
                    }
                    if let file3 = store.model.files[safe: 2], let fileType3 = store.fileModeModels[file3] {
                        imageForFileType(fileType3, model: file3)
                            .frame(width: 60, height: 60)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file3))
                            }
                    }
                }
                HStack {
                    if let file4 = store.model.files[safe: 3], let fileType4 = store.fileModeModels[file4] {
                        imageForFileType(fileType4, model: file4)
                            .frame(width: 80, height: 70)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file4))
                            }
                    }
                    if let file5 = store.model.files[safe: 4], let fileType5 = store.fileModeModels[file5] {
                        imageForFileType(fileType5, model: file5)
                            .frame(width: 80, height: 70)
                            .background(WSXColor.errorRed)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                store.send(.selectedFileURLString(file5))
                            }
                    }
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
            content: "",
            files: [".zip",".zip",".zip",".pdf",".pdf"],
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
