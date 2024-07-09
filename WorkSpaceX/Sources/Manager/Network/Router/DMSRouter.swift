//
//  DMSRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

enum DMSRouter: Router {
    
    case dmRoomListReqeust(_ workSpaceID: String)
    
    case dmRoomUnReadReqeust(_ workSpaceID: String, roomID: String, date: String?)
    
    case dmRoomReqeust(_ workSpaceID: String, requestDTO: DMSRoomRequestDTO)
    
    case dmRoomChatsReqeust(_ workSpaceID: String, roomID: String, date: String?)
    
    case sendDmMessage(_ workSpaceID: String, roomID: String, reqeust: ChatMultipart, boundary: String)
}

extension DMSRouter {
    
    var method: HTTPMethod {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomChatsReqeust :
            return .get
        case .dmRoomReqeust, .sendDmMessage:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .dmRoomListReqeust(let workSpaceID):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
            
        case let .dmRoomUnReadReqeust(workSpaceID, roomID, _):
            return APIKey.version +
            "/workspaces/\(workSpaceID)/dms/\(roomID)/unreads"
            
        case let .dmRoomReqeust(workSpaceID, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms"
            
        case let .dmRoomChatsReqeust(workSpaceID, roomID, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms/\(roomID)/chats"
            
        case let .sendDmMessage(workSpaceID, roomID, _, _):
            return APIKey.version + "/workspaces/\(workSpaceID)/dms/\(roomID)/chats"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomReqeust,
                .dmRoomChatsReqeust :
            return nil
            
        case let .sendDmMessage(_, _, _, boundary):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomReqeust,
                .sendDmMessage:
            return nil
        case let .dmRoomUnReadReqeust(_, _, date):
            if let date {
                return ["after": date]
            } else {
                return nil
            }
        case let .dmRoomChatsReqeust(_,_, date):
            if let date {
                return ["cursor_date": date]
            } else {
                return nil
            }
        }
    }
    
    var body: Data? {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomChatsReqeust :
            return nil
        case let .dmRoomReqeust(_, model):
            return requestToBody(model)
        case let .sendDmMessage(_, _, reqeust, boundary):
            return makeChatMultipartData(reqeust, boundary: boundary)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .dmRoomListReqeust,
                .dmRoomUnReadReqeust,
                .dmRoomChatsReqeust :
            return .url
            
        case .dmRoomReqeust:
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
