//
//  DMSRoomSectionEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation

struct DMSRoomSectionEntity: Entity {
    let id = UUID()
    let name = "다이렉트 메시지"
    /// WorkSpaceChannelRealmModel ->
    var items: [DMSRoomEntity]
}
