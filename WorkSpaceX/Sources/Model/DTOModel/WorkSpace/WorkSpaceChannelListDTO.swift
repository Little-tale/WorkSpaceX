//
//  WorkSpaceChannelListDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import Foundation

struct WorkSpaceChannelListDTO: DTO {
    let chanels: [WorkSpaceChanelsDTO]
    
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var chanels = [WorkSpaceChanelsDTO] ()
        
        while !container.isAtEnd {
            let workSpaceChanel = try container.decode(WorkSpaceChanelsDTO.self)
            chanels.append(workSpaceChanel)
        }
        self.chanels = chanels
    }
}
