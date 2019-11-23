//
//  Schedule.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 10/10/19.
//  Copyright © 2019 Firdavs. All rights reserved.
//

import Foundation

typealias ScheduleResponse = Response<[String: Schedule]>

struct Schedule: Codable {
    let events: Events
    let lectures: Lectures
}

struct ScheduleItem {
    var item: Codable
    
    var time: String
    
    var timeDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.date(from: time)! // Force unwrap because it always returns a date
    }
    
    init<I: Codable>(_ item: I, time: String) {
        self.item = item
        self.time = time
    }
    
    @inlinable
    public func item<I>(as _: I.Type) -> I? {
        return item as? I
    }
}