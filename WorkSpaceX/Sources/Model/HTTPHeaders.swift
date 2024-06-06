//
//  HTTPHeaders.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

typealias HTTPHeaders = [String: String]

extension HTTPHeaders {
    
    @discardableResult
    mutating func addHeaders(_ headers: HTTPHeaders) -> HTTPHeaders {
        headers.forEach { self[$0.key] = $0.value }
        return self
    }
}
