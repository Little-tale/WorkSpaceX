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
         return combine
    }
    
    func asURLRequest() throws -> URLRequest {
        
        guard let url = URL(string: baseURL + path) else {
            throw APIError.httpError("HTTP ERROR -> BAD URL")
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.allHTTPHeaderFields = headers
        
        return try WSXCoder.shared.urlEncoding(request: &urlRequest, parameter: parameters)
        
    }
    
    func requestToBody(_ request: DTORequest) -> Data? {
      return try? WSXCoder.shared.JSONEncode(from: request)
    }
    
}

