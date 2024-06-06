//
//  APIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum APIError: Error, Equatable {
    case httpError(String)
    case customError(APIErrorResponse)
    
    static let Unkonwn = "알수없는 에러"
    
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.customError(let lhsErrorResponse), .customError(let rhsErrorResponse)):
            return lhsErrorResponse == rhsErrorResponse
        default:
            return false
        }
    }
}
