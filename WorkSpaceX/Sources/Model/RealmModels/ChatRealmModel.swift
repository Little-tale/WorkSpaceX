//
//  ChatModelRealmModels.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import Foundation
import RealmSwift

// User정보를 RealmModel 이 아닌 정보와 키를 알게 하도록 변경합니다.

class ChatRealmModel: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var channelID: String
    @Persisted var content: String?
    @Persisted var createdAt: Date?
    @Persisted var user: String // 유저 프라이 머리 키를 갖도록 합니다.
    @Persisted var files: List<String>
    /// 날짜 별 섹션 처럼 보여주기 위한 트리거
    @Persisted var isDateSection: Bool = false
    
    
    convenience
    init(chatID: String, channelID: String, content: String?, createdAt: Date?, user: String, files: [String]) {
        self.init()
        self.chatID = chatID
        self.channelID = channelID
        self.content = content
        self.createdAt = createdAt
        self.user = user
        self.files.append(objectsIn: files)
    }
}
