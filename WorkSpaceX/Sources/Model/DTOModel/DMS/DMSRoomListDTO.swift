//
//  DMSRoomListDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

struct DMSRoomListDTO: DTO {
    let dmsRooms: [DMSRoomDTO]
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var dmsRoomlist = [DMSRoomDTO] ()
        while !container.isAtEnd {
            let dmsRoom = try container.decode(DMSRoomDTO.self)
            dmsRoomlist.append(dmsRoom)
        }
        self.dmsRooms = dmsRoomlist
    }
}

