//
//  ChatModeVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import SwiftUI
//import ComposableArchitecture

struct ChatModeView: View {
    
    enum FileCountCase: Int {
        case none = 0
        case one
        case two
        case three
        case four
        case five
    }
    
    //    @Perception.Bindable var store: StoreOf<ChatModeFeature>
    
    var setModel: ChatModeEntity
    
    @State
    private var fileModeModels: [String: FileType] = [:]
    @State
    private var chatMode: ChatMode = .loading
    @State
    private var fileCountCase: FileCountCase = .none
    
    var profileClicked : ( ChatModeEntity ) -> Void
    var fileClicked: (String) -> Void
    
    var body: some View {
//        WithPerceptionTracking {
//            
//
//        }
        if setModel.isFirstDate {
            VStack(alignment: .center) {
                HStack {
                    Text(DateManager.shared.dateToStringToChatSection(setModel.date))
                        .font(WSXFont.regu1)
                        .foregroundStyle(WSXColor.white)
                        .lineLimit(1)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                }
                .background(
                    WSXColor.black.opacity(0.3)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
        }
        sectionInView()
            .task {
                var fileModels: [String: FileType] = [:]
                
                setModel.files.forEach { file in
                    let type = fileTypeCase(from: file)
                    fileModels[file] = type
                }
                fileCountCase = .init(rawValue: setModel.files.count) ?? .none
                
                fileModeModels = fileModels
                
                chatMode = chatModeResult(model: setModel)
            }
        //            .onAppear {
        //                store.send(.onAppear)
        //            }
    }
    
    private func sectionInView() -> some View {
        HStack(alignment: .top) {
            switch setModel.isMe {
            case .me:
                HStack(alignment: .bottom) {
                    Spacer()
                    Text(DateManager.shared.dateToStringToChat(setModel.date, isMe: true))
                        .font(WSXFont.caption)
                        .padding(.leading, 15)
                    modelCaseView()
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
                        
                        Text(DateManager.shared.dateToStringToChat(setModel.date, isMe: false))
                            .font(WSXFont.caption)
                            .padding(.trailing, 15)
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func modelCaseView() -> some View {
//        WithPerceptionTracking {
//
//        }
        switch chatMode {
        case .text:
            textModeView()
                .modifier(ChatModifier(isMe: setModel.isMe == .me))
        case .File:
            fileCountCaseView(with: fileCountCase)
                .modifier(ChatModifier(isMe: setModel.isMe == .me))
            
        case .textAndFile:
            VStack(alignment: setModel.isMe == .me ? .trailing : .leading) {
                textModeView()
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
                fileCountCaseView(with: fileCountCase)
                    .foregroundStyle(WSXColor.black)
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
            }
            
        case .loading:
            ProgressView()
        }
    }
    
    private func otherProfileView(model: WorkSpaceMemberEntity) -> some View {
//        WithPerceptionTracking {
//
//        }
        HStack {
            if let image = model.profileImage {
                DownSamplingImageView(url: URL(string: image), size: CGSize(width: 100, height: 100))
            } else {
                WSXImage.profileEmpty1
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .asButton {
            profileClicked(setModel)
        }
    }
}

extension ChatModeView {
    
    private func textModeView() -> some View {
//        WithPerceptionTracking {
//
//        }
        Text(setModel.content)
            .font(WSXFont.title2)
    }
}
extension ChatModeView {
    private func fileModeView() -> some View {
//        WithPerceptionTracking {
//            
//        }
        VStack {
            ForEach(setModel.files.enumerated().map { $0 }, id: \.element) { index, file in
                if let fileType = fileModeModels[file] {
                    imageForFileType(fileType, model: file)
                }
            }
        }
    }
    
    @ViewBuilder
    private func imageForFileType(_ fileType: FileType, model: String) -> some View {
        switch fileType {
        case .unknown:
            Image(systemName: "questionmark")
                .resizable()
        case .image:
            DownSamplingImageView(url: URL(string: model), size: CGSize(width: 150, height: 150))
            
        case .pdf:
            VStack {
                Image(systemName: "doc.richtext")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .background(WSXColor.white)
                    .foregroundStyle(WSXColor.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(model.removeForURLChannelChats)
            }
            .font(WSXFont.caption)
        case .zip:
            VStack {
                Image(systemName: "doc.zipper")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .background(WSXColor.white)
                    .foregroundStyle(WSXColor.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(model.removeForURLChannelChats)
            }
            .font(WSXFont.caption)
        }
    }
    
    @ViewBuilder
    private func fileCountCaseView(with caseOF: FileCountCase) -> some View {
//        WithPerceptionTracking {
//
//        }
        switch caseOF {
        case .none:
            EmptyView()
        case .one:
            if let file = setModel.files.first, let fileType = fileModeModels[file] {
                imageForFileType(fileType, model: file)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .asButton {
                        fileClicked(file)
                        //                            store.send(.selectedFileURLString(file))
                    }
            }
        case .two:
            HStack {
                if let file1 = setModel.files[safe: 0], let fileType1 = fileModeModels[file1] {
                    imageForFileType(fileType1, model: file1)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .asButton {
                            fileClicked(file1)
                        }
                }
                if let file2 = setModel.files[safe: 1], let fileType2 = fileModeModels[file2] {
                    imageForFileType(fileType2, model: file2)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .asButton {
                            fileClicked(file2)
                        }
                }
            }
        case .three:
            VStack(alignment: .center) {
                HStack {
                    if let file1 = setModel.files[safe: 0], let fileType1 = fileModeModels[file1] {
                        imageForFileType(fileType1, model: file1)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file1)
                            }
                    }
                    if let file2 = setModel.files[safe: 1], let fileType2 = fileModeModels[file2] {
                        imageForFileType(fileType2, model: file2)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file2)
                            }
                    }
                }
                if let file3 = setModel.files[safe: 2], let fileType3 = fileModeModels[file3] {
                    imageForFileType(fileType3, model: file3)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .asButton {
                            fileClicked(file3)
                        }
                }
            }
        case .four:
            VStack(alignment: .center) {
                HStack {
                    if let file1 = setModel.files[safe: 0], let fileType1 = fileModeModels[file1] {
                        imageForFileType(fileType1, model: file1)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file1)
                            }
                    }
                    if let file2 = setModel.files[safe: 1], let fileType2 = fileModeModels[file2] {
                        imageForFileType(fileType2, model: file2)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file2)
                            }
                    }
                }
                HStack {
                    if let file3 = setModel.files[safe: 2], let fileType3 = fileModeModels[file3] {
                        imageForFileType(fileType3, model: file3)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file3)
                            }
                    }
                    if let file4 = setModel.files[safe: 3], let fileType4 = fileModeModels[file4] {
                        imageForFileType(fileType4, model: file4)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file4)
                            }
                    }
                }
            }
        case .five:
            VStack(alignment: .center) {
                HStack {
                    if let file1 = setModel.files[safe: 0], let fileType1 = fileModeModels[file1] {
                        imageForFileType(fileType1, model: file1)
                            .frame(width: 55, height: 55)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file1)
                            }
                    }
                    if let file2 = setModel.files[safe: 1], let fileType2 = fileModeModels[file2] {
                        imageForFileType(fileType2, model: file2)
                            .frame(width: 55, height: 55)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file2)
                            }
                    }
                    if let file3 = setModel.files[safe: 2], let fileType3 = fileModeModels[file3] {
                        imageForFileType(fileType3, model: file3)
                            .frame(width: 55, height: 55)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file3)
                            }
                    }
                }
                HStack {
                    if let file4 = setModel.files[safe: 3], let fileType4 = fileModeModels[file4] {
                        imageForFileType(fileType4, model: file4)
                            .frame(width: 90, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file4)
                            }
                    }
                    if let file5 = setModel.files[safe: 4], let fileType5 = fileModeModels[file5] {
                        imageForFileType(fileType5, model: file5)
                            .frame(width: 90, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .asButton {
                                fileClicked(file5)
                            }
                    }
                }
            }
        }
    }
}

extension ChatModeView {
    
    private
    func chatModeResult(model: ChatModeEntity) -> ChatMode {
        if model.files.isEmpty {
            return .text
        } else if !model.files.isEmpty && model.content != "" {
            return .textAndFile
        } else {
            return .File
        }
    }
    
    private
    func fileTypeCase(from url: String) -> FileType {
        if url.lowercased().hasSuffix(".jpeg") || url.lowercased().hasSuffix(".png") {
            return .image
        } else if url.lowercased().hasSuffix(".pdf") {
            return .pdf
        } else if url.lowercased().hasSuffix(".zip") {
            return .zip
        } else {
            return .unknown
        }
    }
    
}


//#Preview {
//    ChatModeView(store: Store(
//        initialState: ChatModeFeature.State(model: .init(
//            chatID: "asd",
//            isMe: .me,
//            content: "댓글도 있었을때",
//            files: [
//                "/static/channelChats/면접질문 정리_1701706651157.zip",
//                "/static/channelChats/면접질문 정리_1701706651157.zip",
//                "/static/channelChats/면접질문 정리_1701706651157.zip",
//                "/static/channelChats/면접질문 정리_1701706651157.pdf",
//                "/static/channelChats/면접질문 정리_1701706651157.pdf"
//            ],
//            date: Date())
//        ),
//        reducer: {
//            ChatModeFeature()
//        })
//    )
//}

/*
 .other(.init(
 userID: "TestID",
 email: "이메일",
 nickName: "라일리",
 profileImage: nil)
 )
 */
