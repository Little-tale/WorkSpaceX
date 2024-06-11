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
        
        if !checkRequestInterceptorURLRequest(urlRequest: &request) {
            let data = try await performRequest(request)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        } else {
            try await refreshAccessToken()
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
                print("네트워크 에러코드 :", errorResponse.errorCode)
                if let commonError = CommonError(rawValue: errorResponse.errorCode) {
                    throw APIError.commonError(commonError)
                }
                if AuthError.refreshDeadCode == errorResponse.errorCode {
                    throw APIError.commonError(.refreshDead)
                }
                else {
                    throw APIError.customError(errorResponse.errorCode)
                }
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
    
    private func startIntercept(_ urlRequest: inout URLRequest, retryCount: Int) async throws -> Data {
        let request = intercept(&urlRequest)
        print(request.headers)
        do {
            let data = try await performRequest(request)
            return data
        } catch {
            if retryCount > 0 {
                print("에러 인터셉터 시작.")
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
        print("에러 intercept \(UserDefaultsManager.accessToken)")
        if let access = UserDefaultsManager.accessToken  {
            request.addValue(access, forHTTPHeaderField: WSXHeader.Key.authorization)
        }
        return request
    }
    
    private func refreshAccessToken() async throws {
      
        guard let represh =  UserDefaultsManager.refreshToken,
            let access = UserDefaultsManager.accessToken else {
            throw APIError.httpError("RefreshToken Miss")
        }
        
        UserDefaultsManager.accessToken = nil
        
        print("리프레시전 : ",represh)
        let router = AuthRouter.refreshToken(access: access, token: represh )
        let request = try router.asURLRequest()
        print(request)
        print(request.url)
        print(request.httpMethod)
        print("리프레시 당시 헤더 \(request.headers)")
        let data = try await performRequest(request)
        print("리프레시 당시 데이터 \(data)")
        let result = try WSXCoder.shared.jsonDecoding(model: AccessTokenDTO.self, from: data)
        
        UserDefaultsManager.accessToken = result.accessToken
    }
}
