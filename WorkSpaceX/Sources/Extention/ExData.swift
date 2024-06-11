//
//  ExData.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

extension Data {
    
    mutating func append(_ string: String, encode: String.Encoding = .utf8) {
        guard let data = string.data(using: encode) else {
            return
        }
        append(data)
    }
    
}
