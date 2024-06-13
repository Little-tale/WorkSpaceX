//
//  MapperProtocol.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation

protocol Mapper { }

extension Mapper {
    
    func mappingToURL(with string: String) -> URL? {
        let urlString = APIKey.baseURL + APIKey.version + string
        
        return URL(string: urlString)
    }
}
