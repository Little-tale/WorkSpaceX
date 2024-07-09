//
//  MultiFromData.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

protocol MultipartFromDataType {
    
    func append(
        _ data: Data,
        withName name: String,
        fileName: String?,
        mimeType: String,
        boundary: String
    )
    
    func finalize(boundary: String) -> Data
    
    func headers(boundary: String) -> HTTPHeaders
    
}

final class MultipartFromData: MultipartFromDataType {
    
    private var body = Data()
    
    static func randomBoundary() -> String {
        let first = UInt32.random(in: UInt32.min...UInt32.max)
        let second = UInt32.random(in: UInt32.min...UInt32.max)
        
        return String(format: "workSpaceX.boundary.%08x%08x", first, second)
    }
    
    func append(
        _ data: Data,
        withName name: String,
        fileName: String?,
        mimeType: String,
        boundary: String
    ) {
        // 멀티파트의 시작을 알리는 boundary 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        // Content-Disposition 헤더 추가
        body.append("Content-Disposition: form-data; name=\"\(name)\"".data(using: .utf8)!)
        
        if let fileName = fileName {
            // 파일 이름의 속성을 추가
            body.append("; filename=\"\(fileName)\"".data(using: .utf8)!)
        }
        
        // 헤더의 끝을 알리는 개행
        body.append("\r\n".data(using: .utf8)!)
        
        // Content-Type 헤더 추가
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        // 실제 데이터 추가
        body.append(data)
        
        // 파트의 끝을 알리는 개행 추가
        body.append("\r\n".data(using: .utf8)!)
    }
    
    /// 모든 파트를 추가한 경우 최종 적으로 명시
    func finalize(boundary: String) -> Data {
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    func headers(boundary: String) -> HTTPHeaders {
        return [
            WSXHeader.Key.contentType: "\(WSXHeader.Value.multipartFormData); boundary=\(boundary)"
        ]
    }
}
