//
//  APIError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

enum APIError: Error, Equatable {
    case httpError(String)
    case networkError(String)
    case serverError(String)
    case customError(APIErrorResponse)
    
    
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let lhsMessage), .networkError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.serverError(let lhsMessage), .serverError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.customError(let lhsErrorResponse), .customError(let rhsErrorResponse)):
            return lhsErrorResponse == rhsErrorResponse
        default:
            return false
        }
    }
}
