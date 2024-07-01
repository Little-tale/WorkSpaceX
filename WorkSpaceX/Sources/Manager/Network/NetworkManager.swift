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
        var request = try router.asURLRequest()
        
        
        if !checkRequestInterceptorURLRequest(urlRequest: &request) {
            return try await performRequest(request, errorType: errorType)
        } else {
            let data = try await startIntercept(&request, retryCount: 3, errorType: errorType)
            return data
        }
    }
    
    func requestDto<T: DTO, R: Router, E: WSXErrorType>(_ model: T.Type, router: R, errorType: E.Type) async throws -> T {
        var request = try router.asURLRequest()
        print("요청중인 URL \(request.url)")
        if !checkRequestInterceptorURLRequest(urlRequest: &request) {
            let data = try await performRequest(request, errorType: errorType)
            return try WSXCoder.shared.jsonDecoding(model: T.self, from: data)
        } else {

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
                if errorCode == CommonError.refreshDead.rawValue {
                    RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                }
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
        try await Task.sleep(for: .seconds(0.2))
           let request = intercept(&urlRequest)
           do {
               let data = try await performRequest(request, errorType: errorType)
               return data
           } catch let error as E where retryCount > 0 {
               if error.ifCommonError?.isAccessTokenError == true {
                   try await RefreshTokenManager.shared.refreshAccessToken()
                   
                   return try await startIntercept(&urlRequest, retryCount: retryCount - 1, errorType: errorType)
               } else {
                   throw error
               }
           } catch {
               throw error
           }
       }
    
    private func intercept(_ request: inout URLRequest) -> URLRequest {
        print("유저 바껴야 할것. 엑세스 토큰 \(UserDefaultsManager.accessToken ?? "없음")")
        print("유저 네트워크 주소 \(request.headers)")
        if let access = UserDefaultsManager.accessToken {
            request.setValue(access, forHTTPHeaderField: WSXHeader.Key.authorization)
        }
        print("유저 네트워크 주소 \(request.headers)")
        return request
    }
    
}

