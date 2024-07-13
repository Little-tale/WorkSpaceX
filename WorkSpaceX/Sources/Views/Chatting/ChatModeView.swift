//
//  ChatModeVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import SwiftUI

struct ChatModeView: View {
    
    enum FileCountCase: Int {
        case none = 0
        case one
        case two
        case three
        case four
        case five
    }
    
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
    }
    
    private func sectionInView() -> some View {
        HStack(alignment: .top) {
            switch setModel.isMe {
            case .me:
                HStack(alignment: .bottom) {
                    Spacer()
                    modelCaseView()
                        .padding(.trailing, 10)
                    
                }
            case .other(let member):
                otherProfileView(model: member)
                    .padding(.leading, 10)
                
                VStack (alignment: .leading) {
                    Text(member.nickname)
                        .font(WSXFont.regu1)
                    HStack(alignment:.bottom) {
                        modelCaseView()
                    }
                }
                Spacer()
            }
        }
    }
    
    private func dateView(ifFront: Bool) -> some View {
        Text(DateManager.shared.dateToStringToChat(setModel.date, isMe: ifFront))
            .font(WSXFont.caption)
            .padding(ifFront ? .leading : .trailing, 15)
    }
    
    @ViewBuilder
    private func modelCaseView() -> some View {

        switch chatMode {
        case .text:
            if setModel.isMe == .me {
                dateView(ifFront: setModel.isMe == .me)
                textModeView()
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
            } else {
                textModeView()
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
                dateView(ifFront: setModel.isMe == .me)
            }
            
        case .File:
            if setModel.isMe == .me {
                dateView(ifFront: setModel.isMe == .me)
                fileCountCaseView(with: fileCountCase)
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
               
            } else {
                fileCountCaseView(with: fileCountCase)
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
                dateView(ifFront: setModel.isMe == .me)
            }
            
            
        case .textAndFile:
            VStack(alignment: setModel.isMe == .me ? .trailing : .leading) {
                textModeView()
                    .modifier(ChatModifier(isMe: setModel.isMe == .me))
                if setModel.isMe == .me {
                   
                    HStack(alignment:.bottom ) {
                        dateView(ifFront: setModel.isMe == .me)
                        fileCountCaseView(with: fileCountCase)
                            .foregroundStyle(WSXColor.black)
                            .modifier(ChatModifier(isMe: setModel.isMe == .me))
                    }
                } else {
                    HStack(alignment:.bottom ) {
                        fileCountCaseView(with: fileCountCase)
                            .foregroundStyle(WSXColor.black)
                            .modifier(ChatModifier(isMe: setModel.isMe == .me))
                        dateView(ifFront: setModel.isMe == .me)
                    }
                }
            }
            
        case .loading:
            ProgressView()
        }
    }
    
    private func otherProfileView(model: WorkSpaceMembersEntity) -> some View {
        HStack {
            if let image = model.profileImage {
                DownSamplingImageView(url: URL(string: image), size: ImageResizingCase.middel.size)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
        HStack {
            Text(setModel.content)
                .font(WSXFont.title2)
        }
    }
}
extension ChatModeView {
    
    private func fileModeView() -> some View {
        HStack {
            VStack {
                ForEach(setModel.files.enumerated().map { $0 }, id: \.element) { index, file in
                    if let fileType = fileModeModels[file] {
                        imageForFileType(fileType, model: file)
                    }
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
            DownSamplingImageView(url: URL(string: model), size: ImageResizingCase.middel.size)
            
        case .pdf:
            VStack {
                WSXImage.pdf
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
                WSXImage.zip
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
