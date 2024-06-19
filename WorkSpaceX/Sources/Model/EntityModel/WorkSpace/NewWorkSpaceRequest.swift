//
//  NewWorkSpaceRequest.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

/*
 멀티 파트 프롬 데이터 프로토콜 만들어요 후엥 ^^
 */

struct NewWorkSpaceRequest {
    let name: String
    let description: String?
    let image: Data?
}

struct EditWorkSpaceReqeust {
    let name: String
    let description: String?
    let image: Data?
}
