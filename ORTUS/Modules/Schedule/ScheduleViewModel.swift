//
//  ScheduleViewModel.swift
//  ORTUS
//
//  Created by Firdavs Khaydarov on 25/03/19.
//  Copyright (c) 2019 Firdavs. All rights reserved.
//

import Foundation
import Promises

enum ScheduleGrouping: String, CaseIterable {
    case today, tomorrow, week
}

class ScheduleViewModel: ViewModel {
    typealias Schedule = [(key: String, value: [ScheduleItem])]
    
    let router: ScheduleRouter.Routes
    
    var response: ScheduleResponse?
    
    var schedule: Schedule = []
    
    init(router: ScheduleRouter.Routes) {
        self.router = router
    }
    
    func loadSchedule(forceUpdate: Bool = true) -> Promise<Bool> {
        let today = Date()
        var date = today
        
        if Calendar.current.component(.weekday, from: today) == 1 {
            date = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        }
        
        if !forceUpdate, let response = self.response {
            self.schedule = self.sortSchedule(from: response)
            
            return Promise(true)
        }
        
        return Promise { fulfill, reject in
            APIClient.performRequest(
                ScheduleResponse.self,
                route: ScheduleApi.schedule(date: date)
            ).then { response in
                self.response = response
                self.schedule = self.sortSchedule(from: response)
                
                fulfill(true)
            }.catch { reject($0) }
        }
    }
    
    private func sortSchedule(from response: ScheduleResponse) -> Schedule {
        let sortedResponse = response.result.sorted(by: {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let date0 = dateFormatter.date(from: $0.key),
                let date1 = dateFormatter.date(from: $1.key) else {
                return false
            }
            
            return date0 < date1
        })
        
        var schedule: [(key: String, value: [ScheduleItem])] = []
        for pair in sortedResponse {
            var items: [ScheduleItem] = []
            if UserDefaults.standard.value(for: .showEvents) == true {
                pair.value.events.forEach { items.append(ScheduleItem($0, time: $0.time)) }
            }
            
            pair.value.lectures.forEach { items.append(ScheduleItem($0, time: $0.timeFrom)) }
            items.sort(by: {
                guard let firstDate = $0.timeDate, let secondDate = $1.timeDate else {
                    return false
                }
                
                return firstDate < secondDate
            })
            
            if !items.isEmpty {
                schedule.append((key: pair.key, value: items))
            }
        }
        
        return schedule
    }
}
