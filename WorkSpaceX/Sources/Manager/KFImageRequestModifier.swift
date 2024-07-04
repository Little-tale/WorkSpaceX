//
//  KFImageRequestModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/16/24.
//

import Kingfisher
import Foundation
/*
 회고
 /v1 이 없어지는 현상
 */

final class KFImageRequestModifier: ImageDownloadRequestModifier {
    
    private
    let baseURL = APIKey.baseURL
    
    private
    let version = APIKey.version
    
    func modified(for request: URLRequest) -> URLRequest? {
        
        guard let accessToken = UserDefaultsManager.accessToken else {
            return nil
        }
        
        guard var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        if !urlComponents.path.contains(version) {
            urlComponents.path = version + urlComponents.path
        }
        
        if let baseURLComponents = URLComponents(string: baseURL) {
            urlComponents.scheme = baseURLComponents.scheme
            urlComponents.host = baseURLComponents.host
            urlComponents.port = baseURLComponents.port
        }
        guard let modifiedURL = urlComponents.url else {
            return nil
        }
        var urlRequest = URLRequest(url: modifiedURL)
        
        urlRequest.addValue(accessToken, forHTTPHeaderField: WSXHeader.Key.authorization)
        urlRequest.addValue(APIKey.secretKey, forHTTPHeaderField: WSXHeader.Key.sesacKey)
        
        return urlRequest
    }
}
