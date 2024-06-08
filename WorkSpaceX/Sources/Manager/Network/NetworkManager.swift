//
//  NetworkManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation
import ComposableArchitecture

struct NetworkManager {
    static let shared = NetworkManager()
}

extension NetworkManager {
    
    func request<T: Router>(_ router: T) async throws -> Data {
        let request = try router.asURLRequest()
        return try await performRequest(request)
    }
    
    func requestDto<T: DTO, R: Router>(_ model: T.Type, router: R) async throws -> T {
        var request = try router.asURLRequest()
        
        if checkRequestInterceptorURLRequest(urlRequest: &request) {
            let data = try await performRequest(request)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        } else {
            let data = try await startIntercept(&request, retryCount: 3)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        }
    }
    
    private func performRequest(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkHttpResponse(response: response, data: data)
        return data
    }
    
    private func checkHttpResponse(
        response: URLResponse,
        data: Data
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorResponse = try? WSXCoder.shared.jsonDecoding(model: APIErrorResponse.self, from: data) {
                if let commonError = CommonError(rawValue: errorResponse.errorCode) {
                    throw APIError.commonError(commonError)
                } else {
                    throw APIError.customError(errorResponse)
                }
            } else {
                throw APIError.httpError("Unexpected error: Please retry")
            }
        }
    }
    
    private func checkRequestInterceptorURLRequest(urlRequest: inout URLRequest) -> Bool {
        guard let urlString = urlRequest.url?.absoluteString,
              urlString.hasPrefix(APIKey.baseURL) else {
            return false
        }
        
        if NotNeedInterception.allCases.contains(where: { urlString.contains($0.path)}) {
            return false
        }
        
        return true
    }
    
    private func startIntercept(_ urlRequest: inout URLRequest, retryCount: Int) async throws -> Data {
        let request = intercept(&urlRequest)
        
        do {
            let data = try await performRequest(request)
            return data
        } catch {
            if retryCount > 0 {
                if let apiError = error as? APIError,
                   case .commonError(CommonError.accessToken) = apiError {
                    try await Task.sleep(nanoseconds: 100_000_000)  // 0.1초 지연
                    try await refreshAccessToken()
                    return try await startIntercept(&urlRequest, retryCount: retryCount - 1)
                }
            }
            throw error
        }
    }
    
    private func intercept(_ request: inout URLRequest) -> URLRequest {
        if UserDefaultsManager.accessToken != "" {
            request.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: WSXHeader.Key.authorization)
        }
        return request
    }
    
    private func refreshAccessToken() async throws {
        guard UserDefaultsManager.refreshToken != "" else {
            throw APIError.httpError("RefreshToken Miss")
        }
        
        let router = AuthRouter.refreshToken
        let request = try router.asURLRequest()
        let data = try await performRequest(request)
        let result = try WSXCoder.shared.jsonDecoding(model: AccessTokenDTO.self, from: data)
        
        UserDefaultsManager.accessToken = result.accessToken
    }
}
