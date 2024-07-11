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
        var remove = self.replacingOccurrences(of: "/static/channelChats/", with: "")
        remove = self.replacingOccurrences(of: "/static/dmChats/", with: "")
        return remove
    }
    
    var formatPhoneNumber: String {
        var phoneNumber = self
        if phoneNumber.count >= 12 {
            phoneNumber = String(phoneNumber.prefix(11))
        }
        
        var result = ""
        let mask: String
        
        if phoneNumber.count == 11 {
            mask = "XXX-XXXX-XXXX"
        } else {
            mask = "XXX-XXX-XXXX"
        }
        
        var index = phoneNumber.startIndex
        
        for change in mask where index < phoneNumber.endIndex {
            if change == "X" {
                result.append(phoneNumber[index])
                index = phoneNumber.index(after: index)
            } else {
                result.append(change)
            }
        }
        
        print(result)
        return result
    }
}
