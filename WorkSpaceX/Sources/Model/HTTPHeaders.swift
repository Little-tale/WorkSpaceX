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
        print("옵션 헤더 \(headers)")
        headers.forEach { self[$0.key] = $0.value }
        return self
    }
}
