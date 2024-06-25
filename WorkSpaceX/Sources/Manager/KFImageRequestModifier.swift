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
        
        guard let accessTokken = UserDefaultsManager.accessToken else {
            return nil
        }
//        let str = baseURL + version
//        print("??? dd",str)
        var components = URLComponents(string: baseURL )
        components?.path.append(version)
        if #available(iOS 16.0, *) {
            components?.path.append(contentsOf: (request.url?.path() ?? ""))
        } else {
            components?.path.append(contentsOf: (request.url?.path() ?? ""))
        }
        
        guard let url = components?.url else {
            return nil
        }
        print("이미지 요청 URL: ",url)
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue(accessTokken, forHTTPHeaderField: WSXHeader.Key.authorization)
        
        urlRequest.addValue(APIKey.secretKey, forHTTPHeaderField: WSXHeader.Key.sesacKey)
        
        return urlRequest
    }
}
