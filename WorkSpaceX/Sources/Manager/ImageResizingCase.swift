//
//  ImageResizingCase.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import Foundation

enum ImageResizingCase {
    case big
    case middel
    case small
    case custome(CGSize)
    
    var size: CGSize {
        switch self {
        case .big:
            return CGSize(width: 200, height: 200)
        case .middel:
            return CGSize(width: 150, height: 150)
        case .small:
            return CGSize(width: 100, height: 100)
        case .custome(let size):
            return size
        }
    }
}
