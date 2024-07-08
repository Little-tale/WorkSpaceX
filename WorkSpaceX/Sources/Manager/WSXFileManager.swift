//
//  WSXFileManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import Foundation
import ComposableArchitecture

struct WSXFileManager {
    
    let fileManager = FileManager.default
    
    func fileSave(_ file: Data, urlString: String) -> URL? {
        let fileName = (urlString as NSString).lastPathComponent
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // 파일이 이미 존재하는지 확인
        if fileManager.fileExists(atPath: fileURL.path) {
            // 파일이 존재하면 해당 URL 반환 ->
            return fileURL
        }
    
        do {
            try file.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
}

extension WSXFileManager: DependencyKey {
    static var liveValue: Self = Self()
}

extension DependencyValues {
    var fileManager: WSXFileManager {
        get { self[WSXFileManager.self] }
        set { self[WSXFileManager.self] = newValue }
    }
}
