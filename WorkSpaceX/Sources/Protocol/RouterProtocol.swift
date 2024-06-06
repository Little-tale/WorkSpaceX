//
//  RouterProtocol.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation
import Then

typealias Parameters = [String: Any]

protocol Router {

    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var defaultHeader: HTTPHeaders { get }
    var optionalHeaders: HTTPHeaders { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    var body: Data? { get }
}

enum EncodingType {
    case url
    case json
}

extension Router {
   
    var baseURL: String {
        return APIKey.baseURL
    }
    
    var defaultHeader: HTTPHeaders {
        return [WSXHeader.Key.sesacKey : APIKey.secretKey ]
    }
    
    func asURLRequest() throws -> URLRequest {
        
        guard let url = URL(string: baseURL + path) else {
            throw APIError.httpError("HTTP ERROR -> BAD URL")
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.httpBody = body
        
        urlRequest.allHTTPHeaderFields = headers
       
        do {
            return try Self.encoding(request: &urlRequest, parameter: parameters)
        } catch {
            throw error
        }
    }
    
    static func encoding(request: inout URLRequest, parameter: Parameters?) throws -> URLRequest {
        var urlReqeust = request
        guard let parameter else { return request }
        
        guard let url = urlReqeust.url else {
            throw APIError.httpError("BAD URL")
        }
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.httpError("Bad URLComponents")
        }
        
        urlComponents.queryItems = parameter.map { URLQueryItem(name: $0.key, value: "\($0.value)")}
        urlReqeust.url = urlComponents.url
        
        return urlReqeust
    }
}

