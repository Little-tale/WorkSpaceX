//
//  RouterProtocol.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

protocol Router {
    typealias HTTPHeaders = [String: String]
    typealias Parameters = [String: Any]
    
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var defaultHeaders: HTTPHeaders { get }
    var optionalHeaders: HTTPHeaders { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    var body: Data? { get }
}
