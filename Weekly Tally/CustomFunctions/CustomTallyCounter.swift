//
//  CustomTallyCounter.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/19/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import Foundation

class CustomTallyCounter {

    init() {
    }
    
    public func getTallyForPastXweeks(counter: Counter, Weeks: Int, activeWeeksSelected: Bool) -> Int{
        var tally: Int = 0
        
        let histArrReversed: [Int] = getListOfWeekTallies(counter: counter, activeWeeksSelected: false)

        if histArrReversed.count > Weeks {
            
            var track = 0
            
            for i in 0...histArrReversed.count-1 {
                if(track < Weeks){
                    
                    if(activeWeeksSelected == true && histArrReversed[i] > 0){
                        track += 1
                        tally += histArrReversed[i]
                    }else if(activeWeeksSelected == false){
                        track += 1
                        tally += histArrReversed[i]
                    }
                    
                    if(track == 3){
                        return tally
                    }
                }
            }
        }else {
            for i in 0...histArrReversed.count-1 {
                tally += histArrReversed[i]
            }
        }
        

        return tally
    }
    
    
    public func getListOfWeekTalliesReversed(counter: Counter, activeWeeksSelected: Bool) -> [Int] {
        
        var listOfPastTallies: [Int] = []
        
        var history: String = counter.history ?? ""
    
        if(!history.isEmpty){
            history = history.filter{!$0.isNewline && !$0.isWhitespace}
            
            let histArrReversed: [Int] = history.components(separatedBy: ",").reversed().compactMap { Int($0) }
            
            listOfPastTallies = histArrReversed
            
        }
        
        // Remove all 0 tallies
        if activeWeeksSelected {
            listOfPastTallies.removeAll { $0 == 0 }
        }
        
        return listOfPastTallies
        
    }
    
    
    public func getListOfWeekTallies(counter: Counter, activeWeeksSelected: Bool) -> [Int] {
        
        var listOfPastTallies: [Int] = []
        
        var history: String = counter.history ?? ""
    
        if(!history.isEmpty){
            history = history.filter{!$0.isNewline && !$0.isWhitespace}
            
//            let histArrReversed: [Int] = history.components(separatedBy: ",").reversed().compactMap { Int($0) }
            
            listOfPastTallies = history.components(separatedBy: ",").compactMap { Int($0) }
            
        }
        
        // Remove all 0 tallies
        if activeWeeksSelected {
            listOfPastTallies.removeAll { $0 == 0 }
        }
        
        return listOfPastTallies
        
    }
    
    
    
    public func getTotalWeeks(counter: Counter, DateCreated: Date, pausedPeriod: Int, activeWeeksSelected: Bool) -> Int{
        
        var totalWeeks = 0
        var history: String = counter.history ?? ""
        
        print(counter.title)
        
        if(!history.isEmpty){
            
            history = history.filter{!$0.isNewline && !$0.isWhitespace}
            
            let histArrReversed: [Int] = history.components(separatedBy: ",").reversed().compactMap { Int($0) }

            if(activeWeeksSelected == true){
                histArrReversed.forEach { record in
                    if(record > 0){
                        totalWeeks += 1
                    }
                }
                return totalWeeks
            }else{
                return histArrReversed.count
            }

        }

        return totalWeeks
    }
    

}
