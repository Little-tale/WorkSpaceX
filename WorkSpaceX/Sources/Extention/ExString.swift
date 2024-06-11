//
//  ExString.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

extension String {
    var toData: Data {
        return self.data(using: .utf8) ?? Data()
    }
}
