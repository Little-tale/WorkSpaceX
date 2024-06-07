//
//  DomainErrorType.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/6/24.
//

import Foundation

protocol DomainErrorType: Error, Equatable {
    
    var message: String { get }
    
    var errorCode: String { get }
    
}