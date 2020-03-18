//
//  CustomDate.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/16/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import Foundation

class CustomDate {
    
    init() {
    }
    
    func getFirstDayOfWeek(customDate: Date) -> Date {

        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: customDate)
        let firstDayThisWK = calendar.date(byAdding: .day, value: (1 - dayOfWeek), to: customDate) ?? customDate.addingTimeInterval(TimeInterval((1 - dayOfWeek)*(-86400)))
            
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: firstDayThisWK)
        component.hour = 0
        component.minute = 0
        component.second = 0
                    
        return Calendar.current.date(from: component) ?? firstDayThisWK
    }

    func getLastDayOfWeek(customDate: Date) -> Date? {
        
                       
       let calendar = Calendar.current
       let dayOfWeek = calendar.component(.weekday, from: customDate)
        let lastDayThisWK = calendar.date(byAdding: .day, value: (7-dayOfWeek), to: customDate) ?? customDate.addingTimeInterval(TimeInterval( (7-dayOfWeek)*(86400)))
           
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: lastDayThisWK)
       component.hour = 23
       component.minute = 59
       component.second = 59

        return Calendar.current.date(from: component) ?? lastDayThisWK
    }
    
    func getFirstDayOfNextWeek(customDate: Date) -> Date {

        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: customDate)
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: customDate) ?? customDate.addingTimeInterval(TimeInterval(604800))
        let firstDayNxtWK = calendar.date(byAdding: .day, value: (1 - dayOfWeek), to: nextWeek) ?? customDate.addingTimeInterval(TimeInterval(604800 + (1 - dayOfWeek)*(-86400)))
            
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: firstDayNxtWK)
        component.hour = 0
        component.minute = 0
        component.second = 0
                    
        return Calendar.current.date(from: component) ?? firstDayNxtWK
    }
    
    func getLastDayOfNextWeek(customDate: Date) -> Date {

        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: customDate)
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: customDate) ?? customDate.addingTimeInterval(TimeInterval(604800))
        let lastDayNxtWK = calendar.date(byAdding: .day, value: (7-dayOfWeek), to: nextWeek) ?? customDate.addingTimeInterval(TimeInterval(604800 + ((7-dayOfWeek))*(86400)))
            
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: lastDayNxtWK)
        component.hour = 23
        component.minute = 59
        component.second = 59
                    
        return Calendar.current.date(from: component) ?? lastDayNxtWK
    }
}
