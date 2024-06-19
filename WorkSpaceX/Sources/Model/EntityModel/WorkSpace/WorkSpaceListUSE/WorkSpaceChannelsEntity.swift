//
//  WorkSpaceChannelsEntity.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/19/24.
//

import Foundation

struct WorkSpaceChannelsEntity: Entity, Identifiable {
    let id = UUID()
    let name = "채널"
    var items: [WorkSpaceChannelRealmModel]
}
