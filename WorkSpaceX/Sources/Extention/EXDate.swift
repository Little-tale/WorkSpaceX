//
//  EXDate.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/16/24.
//

import Foundation

extension Date {
    
    var asDateToString: String {
        return DateManager.shared.asDateToString(self)
    }
    
}
