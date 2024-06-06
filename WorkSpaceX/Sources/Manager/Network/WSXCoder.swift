//
//  WSCCoder.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

final class WSXCoder {
    
    static let shared = WSXCoder()
    
    private init () {}
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    
}

extension WSXCoder {
    func JSONEncode<T: Encodable>(from value: T) throws -> Data {
        return try encoder.encode(value)
    }
}

extension WSXCoder {
    
    func urlEncoding(request: inout URLRequest, parameter: [String : Any]?) throws -> URLRequest {
        
        guard let parameter else { return request }
        
        guard let url = request.url else {
            print("Seconde Bad URL")
            throw APIError.httpError("BAD URL")
        }
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("Bad URLComponents")
            throw APIError.httpError("Bad URLComponents")
        }
        
        urlComponents.queryItems = parameter.map { URLQueryItem(name: $0.key, value: "\($0.value)")}
        request.url = urlComponents.url
        print("요청",request)
        return request
    }
    
    func jsonEncoding(request: inout URLRequest, data: Data?) throws -> URLRequest {
        guard let data else { return request }
        
        request.httpBody = data
        
        request.setValue(
            WSXHeader.Value.applicationJson,
            forHTTPHeaderField: WSXHeader.Key.contentType
        )
        
        return request
    }
}

extension WSXCoder {
    func jsonDecoding<T:Decodable>(model: T.Type, from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}
