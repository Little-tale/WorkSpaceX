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
}
extension WorkSpaceRouter {
    var method: HTTPMethod {
        switch self {
        case .meWorkSpace:
            return .get
        case .makeWorkSpace:
            return .post
        case .removeWorkSpace:
            return .delete
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
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .meWorkSpace, .removeWorkSpace:
            return nil
            
        case .makeWorkSpace(_,let boundary):
            let multipartFormData = MultipartFormData()
            return multipartFormData.headers(boundary: boundary)
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .meWorkSpace, .makeWorkSpace, .removeWorkSpace:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .meWorkSpace, .removeWorkSpace:
            return nil
        case let .makeWorkSpace(data, boundary):
            return makeWorkSpaceMultipartData(data, boundary: boundary)
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .meWorkSpace, .removeWorkSpace:
            return .url
        case .makeWorkSpace:
            return .multiPart
        }
    }
    
}
extension WorkSpaceRouter {
    
    func makeWorkSpaceMultipartData(_ data: MakeWorkSpaceDTORequest, boundary: String) -> Data {
        
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
        
        multiPart.append(
            data.image,
            withName: "image",
            fileName: "WorkSpace_\(UUID()).jpeg",
            mimeType: MimeType.image.rawValue,
            boundary: boundary
        )
        
        return multiPart.finalize(boundary: boundary)
        
    }
}

