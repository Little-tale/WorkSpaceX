//
//  DateManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import Foundation

final class DateManager {
    
    private init() {}
    static let shared = DateManager()
    
    private let isoDateFormatter = ISO8601DateFormatter()
    private let dateFormatter = DateFormatter()
    private let locale = Locale(identifier:"ko_KR")
    
    enum dateFormatType: String {
        case slimYDM = "yy. MM. dd"
        case fullType = "yyyyMMMMd"
        case roomListType = "a hh:mm"
        case rightChatType = "a hh시 mm분"
        case leftChatType = "hh시 mm분 a"
        
        var format: String { return self.rawValue}
    }
    
    
    func toDateISO(_ dateString: String) -> Date? {
        var calendar = Calendar.current
        
        isoDateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        calendar.timeZone = .current
        
        return isoDateFormatter.date(from: dateString)
    }
    
    func toDateISO(_ date: Date) -> String {
        
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return isoDateFormatter.string(from: date)
    }
    
    func asDateToString(_ date: Date?) -> String {
        guard let date else { return "" }
        
        dateFormatter.dateFormat = dateFormatType.slimYDM.format
        
        return dateFormatter.string(from: date)
    }
    
    func dateToStringToChat(_ date: Date, isMe: Bool) -> String {
        if isMe {
            dateFormatter.dateFormat = dateFormatType.rightChatType.format
        } else {
            dateFormatter.dateFormat = dateFormatType.leftChatType.format
        }
        
        dateFormatter.locale = locale
        
        return dateFormatter.string(from: date)
    }
    
    func dateToStringToChatSection(_ date: Date) -> String {
        let format = dateFormatType.fullType.format
        dateFormatter.setLocalizedDateFormatFromTemplate(format)
        dateFormatter.locale = locale
        
        return dateFormatter.string(from: date)
    }
    
    func dateToStringToRoomList(_ date: Date) -> String {
        let format = dateFormatType.fullType.format
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = dateFormatType.roomListType.format
        } else {
            dateFormatter.setLocalizedDateFormatFromTemplate(format)
            dateFormatter.locale = locale
        }
        
        return dateFormatter.string(from: date)
    }
    
}
