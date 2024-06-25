//
//  ChatMultipart.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/24/24.
//

import Foundation


struct ChatMultipart: Equatable {
    var content: String?
    var files: [File]?
    
    struct File: Equatable {
        let data: Data
        let fileName: String
        let fileType: FileType
    }
}
