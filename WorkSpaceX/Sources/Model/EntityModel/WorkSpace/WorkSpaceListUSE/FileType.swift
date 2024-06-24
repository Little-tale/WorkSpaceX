//
//  FileType.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/24/24.
//

import Foundation

enum FileType {
    case image
    case pdf
    case zip
    case unknown
    
    var mimeType: String {
        switch self {
        case .image:
            return "image/jpeg"
        case .pdf:
            return "application/pdf"
        case .zip:
            return "application/zip"
        case .unknown:
            return "application/octet-stream"
        }
    }
}

extension FileType {
    
    func fileTypeCase(from url: String) -> FileType {
        if url.lowercased().hasSuffix(".jpeg") || url.lowercased().hasSuffix(".png") {
            return .image
        } else if url.lowercased().hasSuffix(".pdf") {
            return .pdf
        } else if url.lowercased().hasSuffix(".zip") {
            return .zip
        } else {
            return .unknown
        }
    }
    
}
