//
//  WorkSpaceDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import Foundation

struct WorkSpaceaListDTO: DTO {
    let workSpaces: [WorkSpaceDTO]
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var workSpaces = [WorkSpaceDTO] ()
        while !container.isAtEnd {
            let workSpace = try container.decode(WorkSpaceDTO.self)
            workSpaces.append(workSpace)
        }
        self.workSpaces = workSpaces
    }
}
