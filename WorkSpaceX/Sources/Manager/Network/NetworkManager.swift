//
//  NetworkManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

struct NetworkManager {
    static let shared = NetworkManager()
}

extension NetworkManager {
    
    func request<T: Router, E: WSXErrorType>(_ router: T, errorType: E.Type) async throws -> Data {
        let request = try router.asURLRequest()
        return try await performRequest(request, errorType: errorType)
    }
    
    func requestDto<T: DTO, R: Router, E: WSXErrorType>(_ model: T.Type, router: R, errorType: E.Type) async throws -> T {
        var request = try router.asURLRequest()
        
        if !checkRequestInterceptorURLRequest(urlRequest: &request) {
            let data = try await performRequest(request, errorType: errorType)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        } else {
            try await refreshAccessToken()
            let data = try await startIntercept(&request, retryCount: 3, errorType: errorType)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        }
    }
    
    private func performRequest<E: WSXErrorType>(_ request: URLRequest, errorType: E.Type) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        try checkHttpResponse(response: response, data: data, errorType: errorType)
        return data
    }
    
    private func checkHttpResponse<E: WSXErrorType>(
        response: URLResponse,
        data: Data,
        errorType: E.Type
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorResponse = try? WSXCoder.shared.jsonDecoding(model: APIErrorResponse.self, from: data) {
                
                print("네트워크 에러코드 :", errorResponse.errorCode)
                let errorCode = errorResponse.errorCode
            
                let errorInstance = errorType.makeErrorType(from: errorResponse.errorCode)
                
                throw errorInstance
            } else {
                print("에러 : http 관련")
                throw APIError.httpError("Unexpected error: Please retry")
            }
        }
    }
    
    private func checkRequestInterceptorURLRequest(urlRequest: inout URLRequest) -> Bool {
        guard let urlString = urlRequest.url?.absoluteString,
              urlString.hasPrefix(APIKey.baseURL) else {
            print("에러 제외 됩니다. 1")
            return false
        }
        print(urlString)
        if NotNeedInterception.allCases.contains(where: { urlString.contains($0.path)}) {
            print("에러 제외 됩니다. 2")
            return false
        }
        return true
    }
    
    private func startIntercept<E: WSXErrorType>(_ urlRequest: inout URLRequest, retryCount: Int, errorType: E.Type) async throws -> Data {
        let request = intercept(&urlRequest)
        print(request.allHTTPHeaderFields ?? [:])
        do {
            let data = try await performRequest(request, errorType: errorType)
            return data
        }catch let error as E where retryCount > 0 && error.ifCommonError?.isAccessTokenError == true {
            print("에러 인터셉터 시작.")
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1초 지연
            try await refreshAccessToken()
            return try await startIntercept(&urlRequest, retryCount: retryCount - 1, errorType: errorType)
        } catch {
            throw error
        }
    }
    
    private func intercept(_ request: inout URLRequest) -> URLRequest {
        print("에러 intercept \(UserDefaultsManager.accessToken ?? "없음")")
        if let access = UserDefaultsManager.accessToken  {
            request.addValue(access, forHTTPHeaderField: WSXHeader.Key.authorization)
        }
        return request
    }
    
    private func refreshAccessToken() async throws {
        guard let refresh = UserDefaultsManager.refreshToken,
              let access = UserDefaultsManager.accessToken else {
            throw APIError.httpError("RefreshToken Miss")
        }
        
        UserDefaultsManager.accessToken = nil
        
        print("리프레시 전 : ", refresh)
        let router = AuthRouter.refreshToken(access: access, token: refresh)
        let request = try router.asURLRequest()
        print(request)
        print(request.url ?? "없음")
        print(request.httpMethod ?? "없음")
        print("리프레시 당시 헤더 \(request.allHTTPHeaderFields ?? [:])")
        let data = try await performRequest(request, errorType: reFreshError.self)
        print("리프레시 당시 데이터 \(data)")
        let result = try WSXCoder.shared.jsonDecoding(model: AccessTokenDTO.self, from: data)
        
        UserDefaultsManager.accessToken = result.accessToken
    }
}
