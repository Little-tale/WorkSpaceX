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
    case findWorkSpaceChannels(workSpaceID: String)
    case createChannel(MakeWorkSpaceDTORequest, workSpaceID: String, boundary: String)
}
extension WorkSpaceRouter {
    var method: HTTPMethod {
        switch self {
        case .meWorkSpace, .findWorkSpaceChannels:
            return .get
        case .makeWorkSpace, .createChannel:
            return .post
        case .removeWorkSpace:
            return .delete
        case .modifyWorkSpace:
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
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .meWorkSpace, .removeWorkSpace, .findWorkSpaceChannels:
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
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .meWorkSpace, .makeWorkSpace, .removeWorkSpace, .modifyWorkSpace, .findWorkSpaceChannels, .createChannel :
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .meWorkSpace, .removeWorkSpace, .findWorkSpaceChannels:
            return nil
        case let .makeWorkSpace(data, boundary):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
        case let .modifyWorkSpace(data, boundary,_ ):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
        case let .createChannel(data, _, boundary):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .meWorkSpace, .removeWorkSpace, .findWorkSpaceChannels:
            return .url
        case .makeWorkSpace :
            return .multiPart
        case .modifyWorkSpace :
            return .multiPart
        case .createChannel :
            return .multiPart
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
}

