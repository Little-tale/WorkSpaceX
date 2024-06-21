//
//  KFImageRequestModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/16/24.
//

import Kingfisher
import Foundation

final class KFImageRequestModifier: ImageDownloadRequestModifier {
    
    private
    let baseURL = APIKey.baseURL
    
    private
    let version = APIKey.version
    
    func modified(for request: URLRequest) -> URLRequest? {
        print(request.url)
        guard let accessTokken = UserDefaultsManager.accessToken else {
            return nil
        }
        var components = URLComponents(string: baseURL)
        
        if #available(iOS 16.0, *) {
            components?.path = (request.url?.path() ?? "")
        } else {
            components?.path = (request.url?.path ?? "")
        }
        
        guard let url = components?.url else {
            return nil
        }
        print(url)
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue(accessTokken, forHTTPHeaderField: WSXHeader.Key.authorization)
        
        urlRequest.addValue(APIKey.secretKey, forHTTPHeaderField: WSXHeader.Key.sesacKey)
        
        return urlRequest
    }
}
