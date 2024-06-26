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
    
    func toDateISO(_ dateString: String) -> Date? {
        var calender = Calendar.current
        
        isoDateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        calender.timeZone = .current
        
        return isoDateFormatter.date(from: dateString)
    }
    
    func toDateISO(_ date: Date) -> String {
        
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return isoDateFormatter.string(from: date)
    }
    
    func asDateToString(_ date: Date?) -> String {
        guard let date else { return "" }
        
        dateFormatter.dateFormat = "yy. MM. dd"
        
        return dateFormatter.string(from: date)
    }
    
    func dateToStringToChat(_ date: Date, isMe: Bool) -> String {
        if isMe {
            dateFormatter.dateFormat = "a hh시 mm분"
        } else {
            dateFormatter.dateFormat = "hh시 mm분 a"
        }
        
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        return dateFormatter.string(from: date)
    }
    
    func dateToStringToChatSection(_ date: Date) -> String {
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyyMMMMd")
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        return dateFormatter.string(from: date)
    }
    
}
