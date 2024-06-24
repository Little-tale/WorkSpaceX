//
//  ExCollection.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/24/24.
//

import Foundation

extension Collection {
    /// 인덱스 터짐 방지
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
