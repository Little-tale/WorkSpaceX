//
//  WorkSpaceMembersDTO.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import Foundation

struct WorkSpaceMembersDTO: DTO {
    let members: [WorkSpaceAddMemberDTO]
    
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var mambersArray = [WorkSpaceAddMemberDTO] ()
        while !container.isAtEnd {
            let member = try container.decode(WorkSpaceAddMemberDTO.self)
            mambersArray.append(member)
        }
        self.members = mambersArray
    }
}
