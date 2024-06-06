//
//  NetworkManger.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation
import ComposableArchitecture

struct NetworkManger {
    
    static let shared = NetworkManger()
    
}

extension NetworkManger {
    
    func request<T: Router>(_ router: T) async throws -> Data {
        let request = try router.asURLRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResoponse = response as? HTTPURLResponse, (200...299).contains(httpResoponse.statusCode) else {
            if let errorResopnse = try? WSXCoder.shared.jsonDecoding(model: APIErrorResponse.self, from: data) {
                throw APIError.customError(errorResopnse)
            } else {
                throw APIError.networkError("예상치 못한 에러 : RE TRY PLZ")
            }
        }
        
        return data
    }
    
}
