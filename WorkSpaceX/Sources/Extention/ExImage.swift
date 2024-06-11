//
//  ExImage.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import SwiftUI

extension Image {
    
}

extension UIImage {
    
    func imageZipLimit(zipRate: Double) -> Data? {
        let limitBytes = zipRate * 1024 * 1024
        print("클라이언트가 원하는 크기",limitBytes)
        var currentQuality: CGFloat = 0.7
        var imageData = self.jpegData(compressionQuality: currentQuality)
        
        while let data = imageData,
              Double(imageData!.count) > limitBytes && currentQuality > 0{
            print("현재 이미지 크기 :\(data.count)")
            currentQuality -= 0.1
            imageData = self.jpegData(compressionQuality: currentQuality)
            print("현재 압축중인 이미지 크기 :\(imageData?.count ?? 0)")
        }
        
        if let data = imageData,
           Double(data.count) <= limitBytes {
            print("압축 \(data.count) bytes, 압축률: \(currentQuality)")
            return data
            
        } else {
            print("초과")
            return nil
        }
    }
    
}
