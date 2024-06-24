//
//  ChatMultipart.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/24/24.
//

import Foundation


struct ChatMultipart {
    var content: String?
    var files: [(data: Data, fileName: String, fileType: FileType)]?
}
