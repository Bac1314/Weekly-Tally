//
//  WeeklyCounter.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 2/8/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit
import os.log

class Counter: Codable, Equatable{
    static func == (lhs: Counter, rhs: Counter) -> Bool {
         return lhs.title == rhs.title && lhs.dailyGoal == rhs.dailyGoal && lhs.unit == rhs.unit && lhs.dailySum == rhs.dailySum && lhs.weeklySum == rhs.weeklySum && lhs.totalSum == rhs.totalSum && lhs.weeklyGoal == rhs.weeklyGoal && lhs.weekendsIncluded == rhs.weekendsIncluded && lhs.dateCreated == rhs.dateCreated && lhs.dateUpdated == rhs.dateUpdated && lhs.paused == rhs.paused && lhs.pausedPeriod == rhs.pausedPeriod && lhs.history == rhs.history && lhs.dateEnds == rhs.dateEnds
    }
    
    // MARK: Properties
    var title: String
    var dailyGoal: Int
    var unit: String?
    var dailySum: Int
    var weeklySum: Int
    var totalSum: Int
    var weeklyGoal: Int
    var weekendsIncluded: Bool
    var dateCreated: Date
    var dateEnds: Date?
    var dateUpdated: Date
    var paused: Bool?
    var pausedPeriod: Int?
    var history: String?
    
    
    // New Counter
    init?(title: String, unit: String?, weeklyGoal: Int, weekendsIncluded: Bool){
        
        guard !title.isEmpty else {
            return nil
        }
        
        guard weeklyGoal > 0 else {
            return nil
        }
        
        //User values
        self.title = title
        self.unit = unit ?? "counts"
        self.weeklyGoal = weeklyGoal
        self.weekendsIncluded = weekendsIncluded
    
               //Auto values
        if(weekendsIncluded) {
            self.dailyGoal = Int(round(Double(weeklyGoal)/7.0))}
        else{
            self.dailyGoal = Int(round(Double(weeklyGoal)/5.0))}
        self.dailySum = 0
        self.weeklySum = 0
        self.totalSum = 0
        self.dateCreated = Date()
        self.dateUpdated = Date()
        self.paused = false
        self.pausedPeriod = 0
    }
    
    // Existing Counter
    init?(title: String, dailyGoal:Int, unit: String?, dailySum: Int, weeklySum: Int, totalSum: Int,  weeklyGoal: Int, weekendsIncluded: Bool, dateCreated: Date, dateEnds: Date?, dateUpdated: Date, paused: Bool?, pausedPeriod: Int?, history: String?){
 
        guard !title.isEmpty else {
            return nil
        }
        
        guard weeklyGoal > 0 else {
            return nil
        }
        
        //User values
        self.title = title
        self.unit = unit ?? "counts"
        self.weeklyGoal = weeklyGoal
        self.weekendsIncluded = weekendsIncluded
        self.dailyGoal = dailyGoal
        self.dailySum = dailySum
        self.weeklySum = weeklySum
        self.totalSum = totalSum
        self.dateCreated = dateCreated
        self.dateEnds = dateEnds
        self.dateUpdated = dateUpdated
        self.paused = paused
        self.pausedPeriod = pausedPeriod
        self.history = history
    }
    
    // MARK: Private functions
    func getDailyGoal() -> Int{
        var dailyGoal: Int = 0
        
        //Auto values
        if(weekendsIncluded) {
            dailyGoal = Int(round(Double(weeklyGoal)/7.0))}
        else{
            dailyGoal = Int(round(Double(weeklyGoal)/5.0))}
        
        if(dailyGoal == 0){
            dailyGoal = 1
        }
        
        return dailyGoal
    }
 
}
