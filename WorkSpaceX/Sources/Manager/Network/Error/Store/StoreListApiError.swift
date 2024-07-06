//
//  StoreListApiError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import Foundation

struct StoreListApiError: WSXErrorType {
    var errorCode: String
    
    var thisErrorCodes: [String] = []
    
    var message: String = ""
    
    var ifDevelopError: Bool = true
    
    static func makeErrorType(from customError: String) -> Self {
        return Self(errorCode: customError)
    }
}
