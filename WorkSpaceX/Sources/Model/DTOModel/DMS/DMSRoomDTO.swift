//
//  DMSRoomDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

struct DMSRoomDTO: DTO {
   
    let room_id: String
    
    let createdAt: String
    
    let user: WorkSpaceAddMemberDTO
    
}
