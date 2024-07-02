//
//  DMChatRealmModel.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/2/24.
//

import Foundation
import RealmSwift

class DMChatRealmModel: Object {
    
    @Persisted(primaryKey: true) var dmID: String
    @Persisted var roomID: String
    @Persisted var content: String?
    @Persisted var createdAt: Date?
    @Persisted var user: String // 유저 프라이 머리 키를 갖도록 합니다.
    @Persisted var files: List<String>
    /// 날짜 별 섹션 처럼 보여주기 위한 트리거
    @Persisted var isDateSection: Bool = false
    
    
    convenience
    init(dmID: String, roomID: String, content: String? = nil, createdAt: Date? = nil, user: String, files: List<String>, isDateSection: Bool) {
        self.init()
        self.dmID = dmID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.user = user
        self.files = files
        self.isDateSection = isDateSection
    }
}
