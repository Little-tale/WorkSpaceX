//
//  WorkSpaceRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation

enum WorkSpaceRouter: Router {
    case meWorkSpace
    case makeWorkSpace(MakeWorkSpaceDTORequest, randomBoundary: String)
    case removeWorkSpace(workSpaceId: String)
    case modifyWorkSpace(ModifyWorkSpaceDTORequest, randomBoundary: String, workSpaceID: String)
    
    // 채널
    case channelListSearching(workSpaceId: String)
    case findWorkSpaceChannels(workSpaceID: String)
    case createChannel(MakeWorkSpaceDTORequest, workSpaceID: String, boundary: String)
    case workSpaceAddMember(workSpaceId: String, request: WorkSpaceAddMemberRequestDTO)
    
    case workSpaceMembersReqeust(workSpaceId: String)
    
    case workSpaceChatRequest(workSpaceId: String, channelID: String, ifDate: String?)
    
    case channelInfoReqesut(workSpaceId: String, channelID: String)
    
    case sendChat(workSpaceID: String, _ ChannelID: String,_ multi: ChatMultipart, boundary: String)
    
    case exitChannel(workSpaceID: String, _ ChannelID: String)
    
    case editToChannel(workSpaceID: String, _ ChannelID: String, multi: ModifyWorkSpaceDTORequest, randomBoundary: String)
    
    case channelOwnerChanged(workSpaceId: String, ChannelID: String, request: ChannelOwnerRequestDTO)
    
    case channelDelete(workSpaceID: String, channelID: String)
    
    case reqeustUser(userID: String)
}
extension WorkSpaceRouter {
    var method: HTTPMethod {
        switch self {
        case .meWorkSpace,
                .findWorkSpaceChannels,
                .workSpaceMembersReqeust,
                .channelListSearching,
                .workSpaceChatRequest,
                .channelInfoReqesut,
                .exitChannel,
                .reqeustUser :
            return .get
        case .makeWorkSpace, .createChannel, .workSpaceAddMember, .sendChat:
            return .post
        case .removeWorkSpace, .channelDelete:
            return .delete
        case .modifyWorkSpace, .editToChannel, .channelOwnerChanged:
            return .put
            
        }
    }
    
    var path: String {
        switch self {
        case .meWorkSpace:
            return APIKey.version + "/workspaces"
            
        case .makeWorkSpace:
            return APIKey.version + "/workspaces"
            
        case .removeWorkSpace(workSpaceId: let workSpaceId):
            return APIKey.version + "/workspaces/\(workSpaceId)"
            
        case let .modifyWorkSpace(_, _, id ):
            return APIKey.version + "/workspaces/\(id)"
            
        case let .findWorkSpaceChannels(id):
            return APIKey.version + "/workspaces/\(id)/my-channels"
            
        case let .createChannel(_, id, _):
            print("라우터 시점 :\(id)")
            return APIKey.version + "/workspaces/\(id)/channels"
            
        case let .workSpaceAddMember(id,_):
            return APIKey.version + "/workspaces/\(id)/members"
            
        case let .workSpaceMembersReqeust(id):
            return APIKey.version + "/workspaces/\(id)/members"
        case let .channelListSearching(id):
            return APIKey.version + "/workspaces/\(id)/channels"
            
        case let .workSpaceChatRequest(workSpace, channel, _) :
            
            return APIKey.version +  "/workspaces/\(workSpace)/channels/\(channel)/chats"
            
        case let .channelInfoReqesut(workSpace, channel):
            return APIKey.version + "/workspaces/\(workSpace)/channels/\(channel)"
            
        case let .sendChat(workSpace, channel, _, _):
            return APIKey.version + "/workspaces/\(workSpace)/channels/\(channel)/chats"
            
        case let .exitChannel(workSpaceID, channelID):
            print("나가기 시도 -> \(workSpaceID) -> \(channelID)")
            return APIKey.version + "/workspaces/\(workSpaceID)/channels/\(channelID)/exit"
            
        case let .editToChannel(workSpaceID, channelID, _, randomBoundary):
            return APIKey.version + "/workspaces/\(workSpaceID)/channels/\(channelID)"
            
        case let .channelOwnerChanged(workSpace,channel,_):
            return APIKey.version + "/workspaces/\(workSpace)/channels/\(channel)/transfer/ownership"
            
        case let .channelDelete(workSpace, channel):
            return APIKey.version + "/workspaces/\(workSpace)/channels/\(channel)"
            
        case let .reqeustUser(userID):
            return APIKey.version + "/users/\(userID)"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .meWorkSpace,
                .removeWorkSpace,
                .findWorkSpaceChannels,
                .workSpaceAddMember,
                .workSpaceMembersReqeust,
                .channelListSearching,
                .channelInfoReqesut,
                .exitChannel,
                .channelOwnerChanged,
                .channelDelete,
                .reqeustUser :
            return nil
            
        case .makeWorkSpace(_,let boundary):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
        case let .modifyWorkSpace(_, boundary, _):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
            
        case let .createChannel(_, _, boundary) :
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
            
        case .workSpaceChatRequest:
            return  [
                "accept" : WSXHeader.Value.applicationJson
            ]
            
        case let .sendChat(_,_,_, boundary):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
        case let .editToChannel(_, _, _, boundary):
            let multipartFoemData = MultipartFormData()
            return multipartFoemData.headers(boundary: boundary)
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .meWorkSpace, .makeWorkSpace, .removeWorkSpace, .modifyWorkSpace, .findWorkSpaceChannels, .createChannel, .workSpaceAddMember, .workSpaceMembersReqeust, .channelListSearching,
                .channelInfoReqesut,
                .sendChat,
                .exitChannel,
                .editToChannel,
                .channelOwnerChanged,
                .channelDelete,
                .reqeustUser :
            return nil
            
        case let .workSpaceChatRequest(_, _, date):
            if let date {
                return ["cursor_date": date]
            } else {
                return nil
            }
        }
    }
    
    var body: Data? {
        switch self {
        case .meWorkSpace,
                .removeWorkSpace,
                .findWorkSpaceChannels,
                .workSpaceMembersReqeust,
                .channelListSearching,
                .workSpaceChatRequest,
                .channelInfoReqesut,
                .exitChannel,
                .channelDelete,
                .reqeustUser :
            return nil
        case let .makeWorkSpace(data, boundary):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
        case let .modifyWorkSpace(data, boundary,_ ):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
        case let .createChannel(data, _, boundary):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
            
        case let .workSpaceAddMember(_, model):
            return requestToBody(model)
            
            
        case let .sendChat(_, _, model, boundary):
            return makeChatMultipartData(model, boundary: boundary)
            
        case let .editToChannel(_,_, model, boundary):
            return makeWorkSpaceMultipartData(model, boundary: boundary)
        case let .channelOwnerChanged(_,_,request):
            return requestToBody(request)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .meWorkSpace,
                .removeWorkSpace,
                .findWorkSpaceChannels,
                .workSpaceMembersReqeust,
                .channelListSearching,
                .workSpaceChatRequest,
                .channelInfoReqesut,
                .exitChannel,
                .channelDelete,
                .reqeustUser :
            return .url
            
        case .makeWorkSpace :
            return .multiPart
            
        case .modifyWorkSpace :
            return .multiPart
            
        case .createChannel :
            return .multiPart
            
        case .sendChat:
            return .multiPart
            
        case .editToChannel:
            return .multiPart
            
        case .workSpaceAddMember, .channelOwnerChanged:
            return .json
        }
    }
    
}
extension WorkSpaceRouter {
    
    private func makeWorkSpaceMultipartData(_ data: MakeWorkSpaceDTORequest, boundary: String) -> Data {
        
        let multiPart = MultipartFormData()
        
        multiPart.append(
            data.name.toData,
            withName: "name",
            fileName: nil,
            mimeType: MimeType.text.rawValue,
            boundary: boundary
        )
        
        if let description = data.description {
            multiPart.append(
                description.toData,
                withName: "description",
                fileName: nil,
                mimeType: MimeType.text.rawValue,
                boundary: boundary
            )
        }
        
        if let image = data.image {
            multiPart.append(
                image,
                withName: "image",
                fileName: "WorkSpace_\(UUID()).jpeg",
                mimeType: MimeType.image.rawValue,
                boundary: boundary
            )
        }
        
        return multiPart.finalize(boundary: boundary)
        
    }
    
    private func makeWorkSpaceMultipartData(_ data: ModifyWorkSpaceDTORequest, boundary: String) -> Data {
        
        let multiPart = MultipartFormData()
        
        multiPart.append(
            data.name.toData,
            withName: "name",
            fileName: nil,
            mimeType: MimeType.text.rawValue,
            boundary: boundary
        )
        
        if let description = data.description {
            multiPart.append(
                description.toData,
                withName: "description",
                fileName: nil,
                mimeType: MimeType.text.rawValue,
                boundary: boundary
            )
        }
        
        if let image = data.image {
            multiPart.append(
                image,
                withName: "image",
                fileName: "WorkSpace_\(UUID()).jpeg",
                mimeType: MimeType.image.rawValue,
                boundary: boundary
            )
        }
        
        return multiPart.finalize(boundary: boundary)
    }
    
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

