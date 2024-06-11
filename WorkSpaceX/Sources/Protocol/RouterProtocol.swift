//
//  RouterProtocol.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

typealias Parameters = [String: Any]

protocol Router {
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var defaultHeader: HTTPHeaders { get }
    var optionalHeaders: HTTPHeaders? { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    var body: Data? { get }
    var encodingType: EncodingType { get }
}
enum EncodingType {
    case url
    case json
    case multiPart
}

enum MimeType: String {
    case text = "text/plain"
    case image = "image/jpeg"
}

extension Router {
    
    
   
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var defaultHeader: HTTPHeaders {
        return [WSXHeader.Key.sesacKey : APIKey.secretKey ]
    }
    var headers: HTTPHeaders {
        var combine = defaultHeader
        if let optionalHeaders {
            combine.addHeaders(optionalHeaders)
        }
        print(combine)
         return combine
    }
    
    func asURLRequest() throws -> URLRequest {
        
        guard let url = URL(string: baseURL + path) else {
            print("HTTP ERROR - BAD URL")
            throw APIError.httpError("HTTP ERROR -> BAD URL")
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        switch encodingType {
        case .url:
            return try WSXCoder.shared.urlEncoding(request: &urlRequest, parameter: parameters)
        case .json:
            return try WSXCoder.shared.jsonEncoding(request: &urlRequest, data: body)
        case .multiPart:
            urlRequest.httpBody = body
            return urlRequest
        }
    }
    
    func requestToBody(_ request: DTORequest) -> Data? {
        let result = try? WSXCoder.shared.JSONEncode(from: request)
        print("iF nil is Faile ", result ?? "Not Nil")
        return result
    }
    
}

