//
//  StoreItemListDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation

struct StoreItemListDTO: DTO {
    let itemList: [StoreItemDTO]

    init(from decoder: any Decoder) throws {
        var contatiner = try decoder.unkeyedContainer()
        var itemList = [StoreItemDTO] ()
        while !contatiner.isAtEnd {
            let item = try contatiner.decode(StoreItemDTO.self)
            itemList.append(item)
        }
        self.itemList = itemList
    }
}
