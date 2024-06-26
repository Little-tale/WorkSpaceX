//
//  ChatModelRealmModels.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import Foundation
import RealmSwift

class ChatRealmModel: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var channelID: String
    @Persisted var content: String?
    @Persisted var createdAt: Date?
    @Persisted var user: UserRealmModel?
    @Persisted var files: List<String>
    /// 날짜 별 섹션 처럼 보여주기 위한 트리거
    @Persisted var isDateSection: Bool = false
    
    
    convenience
    init(chatID: String, channelID: String, content: String?, createdAt: Date?, user: UserRealmModel?, files: [String]) {
        self.init()
        self.chatID = chatID
        self.channelID = channelID
        self.content = content
        self.createdAt = createdAt
        self.user = user
        self.files.append(objectsIn: files)
    }
}
