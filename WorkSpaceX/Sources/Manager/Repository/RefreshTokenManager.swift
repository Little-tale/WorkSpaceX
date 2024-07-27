//
//  TokenManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

actor RefreshTokenManager {
    static let shared = RefreshTokenManager()
    
    private var isRefreshing = false
    private var pendingRequests: [CheckedContinuation<Void, Error>] = []
    
    func refreshAccessToken() async throws {
        if isRefreshing {
            // 다른 갱신 요청이 이미 진행 중인 경우, 완료될 때까지 대기
            return try await withCheckedThrowingContinuation { continuation in
                pendingRequests.append(continuation)
            }
        }
        isRefreshing = true
        defer {
            isRefreshing = false
            pendingRequests.forEach { $0.resume() }
            pendingRequests.removeAll()
        }
        
        do {
            print("유저 리프레시 \(UserDefaultsManager.refreshToken ?? "nil")")
            print("유저 엑세스 \(UserDefaultsManager.accessToken ?? "nil")")
            
            try await Task.sleep(for: .seconds(0.3))
            
            guard let refresh = UserDefaultsManager.refreshToken else {
                print("리프레시 Miss \(UserDefaultsManager.refreshToken ?? "nil")")
                throw APIError.httpError("엑세스 Miss")
            }
            guard let access = UserDefaultsManager.accessToken else {
                print("엑세스 Miss \(UserDefaultsManager.accessToken ?? "nil")")
                
                RefreshTokenDeadReceiver.shared.postRefreshTokenDead()
                return
            }
            
            print("리프레시 전 : ", refresh)
            let router = AuthRouter.refreshToken(access: access, token: refresh)
            let request = try router.asURLRequest()
            print(request)
            print(request.url ?? "없음")
            print(request.httpMethod ?? "없음")
            print("리프레시 당시 헤더 \(request.allHTTPHeaderFields ?? [:])")
            let data = try await performRequest(request, errorType: reFreshError.self)
            print("리프레시 당시 데이터 \(data.base64EncodedString())")
            let result = try WSXCoder.shared.jsonDecoding(model: AccessTokenDTO.self, from: data)
            print("리프레시 당시 데이터2 \(result)")
            UserDefaultsManager.accessToken = result.accessToken
            
            // 대기 중인 요청들에 대해 성공 응답
            for pending in pendingRequests {
                pending.resume()
            }
            
            pendingRequests.removeAll()
            
        } catch {
            // 대기 중인 요청들에 대해 실패 응답
            for pending in pendingRequests {
                pending.resume(throwing: error)
            }
            
            pendingRequests.removeAll()
            throw error
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
                if errorResponse.errorCode == CommonError.refreshDead.rawValue {
                    RefreshTokenDeadReceiver.shared.postRefreshTokenDead()
                }
                let errorInstance = errorType.makeErrorType(from: errorResponse.errorCode)
                throw errorInstance
            } else {
                throw APIError.httpError("Unexpected error: Please retry")
            }
        }
    }
}
