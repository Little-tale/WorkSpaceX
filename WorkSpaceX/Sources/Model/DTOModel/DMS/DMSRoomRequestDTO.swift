//
//  DMSRoomRquestDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation

struct DMSRoomRequestDTO: DTORequest {
    /// 다른 사용자의 아이디
    let opponent_id: String
}
