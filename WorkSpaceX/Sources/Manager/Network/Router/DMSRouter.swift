//
//  DMSRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

enum DMSRouter: Router {
    
    case dmRoomListRequest(_ workSpaceID: String)
    
    case dmRoomUnReadRequest(_ workSpaceID: String, roomID: String, date: String?)
    
    case dmRoomRequest(_ workSpaceID: String, requestDTO: DMSRoomRequestDTO)
    
    case dmRoomChatsRequest(_ workSpaceID: String, roomID: String, date: String?)
    
    case sendDmMessage(_ workSpaceID: String, roomID: String, request: ChatMultipart, boundary: String)
}

extension DMSRouter {
    
    var method: HTTPMethod {
        switch self {
        case .dmRoomListRequest,
                .dmRoomUnReadRequest,
                .dmRoomChatsRequest :
            return .get
        case .dmRoomRequest, .sendDmMessage:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .dmRoomListRequest(let workSpaceID):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
            
        case let .dmRoomUnReadRequest(workSpaceID, roomID, _):
            return APIKey.version +
            "/workspaces/\(workSpaceID)/dms/\(roomID)/unreads"
            
        case let .dmRoomRequest(workSpaceID, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
            
        case let .dmRoomChatsRequest(workSpaceID, roomID, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms/\(roomID)/chats"
            
        case let .sendDmMessage(workSpaceID, roomID, _, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms/\(roomID)/chats"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .dmRoomListRequest,
                .dmRoomUnReadRequest,
                .dmRoomRequest,
                .dmRoomChatsRequest :
            return nil
            
        case let .sendDmMessage(_, _, _, boundary):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .dmRoomListRequest,
                .dmRoomRequest,
                .sendDmMessage:
            return nil
        case let .dmRoomUnReadRequest(_, _, date):
            if let date {
                return ["after": date]
            } else {
                return nil
            }
        case let .dmRoomChatsRequest(_,_, date):
            if let date {
                return ["cursor_date": date]
            } else {
                return nil
            }
        }
    }
    
    var body: Data? {
        switch self {
        case .dmRoomListRequest,
                .dmRoomUnReadRequest,
                .dmRoomChatsRequest :
            return nil
        case let .dmRoomRequest(_, model):
            return requestToBody(model)
        case let .sendDmMessage(_, _, request, boundary):
            return makeChatMultipartData(request, boundary: boundary)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .dmRoomListRequest,
                .dmRoomUnReadRequest,
                .dmRoomChatsRequest :
            return .url
            
        case .dmRoomRequest:
            return .json
            
        case .sendDmMessage:
            return .multiPart
        }
    }
    
}

extension DMSRouter {
    
    private func makeChatMultipartData(_ data: ChatMultipart, boundary: String) -> Data {
        
        let multiPart = MultipartFormData()
        
        if let content = data.content {
            if content != "" {
                multiPart.append(
                    content.toData,
                    withName: "content",
                    fileName: nil,
                    mimeType: MimeType.text.rawValue,
                    boundary: boundary
                )
            }
        }
        if let datas = data.files {
            dump(datas)
            for file in datas {
                multiPart.append(
                    file.data,
                    withName: "files",
                    fileName: file.fileName,
                    mimeType: file.fileType.mimeType,
                    boundary: boundary
                )
            }
        }
        
        return multiPart.finalize(boundary: boundary)
    }
    
}
