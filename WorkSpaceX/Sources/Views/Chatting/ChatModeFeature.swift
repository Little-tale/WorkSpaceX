//
//  ChatModeFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ChatModeFeature {
    
    enum FileCountCase: Int {
        case none = 0
        case one
        case two
        case three
        case four
        case five
    }
    
    enum FileType {
        case unknown
        case image
        case PDF
        case ZIP
    }
    
    @ObservableState
    struct State: Equatable, Identifiable {
        var id = UUID()
        
        let model: ChatModeEntity
        var fileModeModels: [String: FileType] = [:]
        var chatMode: ChatMode = .loading
        var fileCountCase: FileCountCase = .none
    }
    
    enum Action {
        case onAppear
        
        case delegate(Delegate)
        
        case profileClicked
        
        case selectedFileURLString(String)
        
        enum Delegate {
            case selectedProfile(WorkSpaceMemberEntity)
            case selectedFileURLString(String)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                
                var fileModeModels: [String: FileType] = [:]
                
                state.model.files.forEach { file in
                    let type = fileTypeCase(from: file)
                    fileModeModels[file] = type
                }
                state.fileCountCase = .init(rawValue: state.model.files.count) ?? .none
                
                state.fileModeModels = fileModeModels
                
                state.chatMode = chatModeResult(model: state.model)
                
            case .profileClicked:
                switch state.model.isMe {
                    
                case .me:
                    break
                    
                case let .other(member):
                    return .run { send in
                        await send(.delegate(.selectedProfile(member)))
                    }
                }
                
            case let .selectedFileURLString(urlString):
                return .run { send in
                    await send(.delegate(.selectedFileURLString(urlString)))
                }
                
            default:
                break
            }
            
            return .none
        }
    }
}

extension ChatModeFeature {
    
    func fileTypeCase(from url: String) -> FileType {
        if url.lowercased().hasSuffix(".jpeg") || url.lowercased().hasSuffix(".png") {
            return .image
        } else if url.lowercased().hasSuffix(".pdf") {
            return .PDF
        } else if url.lowercased().hasSuffix(".zip") {
            return .ZIP
        } else {
            return .unknown
        }
    }
    
}

extension ChatModeFeature {
    func chatModeResult(model: ChatModeEntity) -> ChatMode {
        if model.files.isEmpty {
            return .text
        } else if !model.files.isEmpty && model.content != "" {
            return .textAndFile
        } else {
            return .File
        }
    }
}
