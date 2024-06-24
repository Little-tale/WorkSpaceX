//
//  ExString.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/11/24.
//

import Foundation

extension String {
    var toData: Data {
        return self.data(using: .utf8) ?? Data()
    }
    
    var toDate: Date? {
        return DateManager.shared.toDateISO(self)
    }
    
    var removeForURLChannelChats: String {
        let remove = self.replacingOccurrences(of: "/static/channelChats/", with: "")
        return remove
    }
}
