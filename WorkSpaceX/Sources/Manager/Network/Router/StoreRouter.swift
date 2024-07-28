//
//  StoreRouter.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation

enum StoreRouter: Router {
 
    case storeValidation(request: StoreValidationRequestDTO)
    
    case storeItemList
    
}

extension StoreRouter {
    
    var method: HTTPMethod {
        switch self {
        case .storeValidation:
            return .post
        case .storeItemList:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .storeValidation:
            return APIKey.version + "/store/pay/validation"
            
        case .storeItemList:
            return APIKey.version + "/store/item/list"
        }
    }
    
    var optionalHeaders: HTTPHeaders? {
        switch self {
        case .storeValidation, .storeItemList:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .storeValidation, .storeItemList:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .storeValidation(let request):
            return requestToBody(request)
            
        case .storeItemList:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .storeValidation:
            return .json
            
        case .storeItemList:
            return .url
        }
    }
    
}
