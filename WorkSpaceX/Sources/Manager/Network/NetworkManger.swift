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
        print(request)
        try checkHttpResponse(response: response, data: data)
        return data
    }
    
    func requestDto<T:DTO, R: Router>(_ model: T.Type, router: R) async throws -> T {
        var request = try router.asURLRequest()
        
        if checkRequestInterceptorURLRequest(urlRequest: &request) {
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            try checkHttpResponse(response: response, data: data)
            
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
            
        } else {
            let data = try await startIntercept(&request, retryCount: 3)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        }
    }
    
    private func checkHttpResponse(
        response:  URLResponse,
        data: Data
    ) throws {
        print(response)
        guard let httpResoponse = response as? HTTPURLResponse, (200...299).contains(httpResoponse.statusCode) else {
            if let errorResopnse = try? WSXCoder.shared.jsonDecoding(model: APIErrorResponse.self, from: data) {
                print("Error For: \(errorResopnse.errorCode)")
                if let commonError = CommonError(rawValue: errorResopnse.errorCode) {
                    throw APIError.commonError(commonError)
                } else {
                    throw APIError.customError(errorResopnse)
                }
            } else {
                throw APIError.httpError("예상치 못한 에러 : RE TRY PLZ")
            }
        }
    }
    
    private func checkRequestInterceptorURLRequest(urlRequest: inout URLRequest) -> Bool {
        // baseURL : www.naver.com
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
        var request = intercept(&urlRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try checkHttpResponse(response: response, data: data)
            return data
        } catch {
            if retryCount > 0 {
                if let apiError = error as? APIError, apiError == .customError(APIErrorResponse(errorCode: "E05")) {
                    // 토큰 갱신
                    try await refreshAccessToken()
                    // 재시도 시 retryCount 감소
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
        guard UserDefaultsManager.refreshToken != ""else {
            throw APIError.httpError("RefreshToken Miss")
        }
        
        let router = AuthRouter.refreshToken
        let request = try router.asURLRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResoponse = response as? HTTPURLResponse, (200...299).contains(httpResoponse.statusCode) else {
            if let errorResopnse = try? WSXCoder.shared.jsonDecoding(model: APIErrorResponse.self, from: data) {
                print("Error For: \(errorResopnse.errorCode)")
                throw APIError.customError(errorResopnse)
            } else {
                throw APIError.httpError("예상치 못한 에러 : RE TRY PLZ")
            }
        }
        
        let result = try WSXCoder.shared.jsonDecoding(model: AccessTokenDTO.self, from: data)
        
        UserDefaultsManager.accessToken = result.accessToken
    }
    
    
}
