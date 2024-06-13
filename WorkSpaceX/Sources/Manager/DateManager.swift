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
    
    func toDateISO(_ dateString: String) -> Date? {
        var calender = Calendar.current
        
        isoDateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        calender.timeZone = .current
        
        return isoDateFormatter.date(from: dateString)
    }
    
}
