//
//  RecordViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/8/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit


class RecordViewController: UIViewController{

    var counters = [Counter]()
    var countersRecords = [[records]]()
    let segmentTitles = [ "Total", "Last Week", "Last 3 Weeks"]
    var activeWeeksSelected = false
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activeWeeksBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecords()
    }



//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
    

    // MARK: - functions
    public func getTotalWeeks(counter: Counter, DateCreated: Date, pausedPeriod: Int) -> Int{
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
//                let compToday = Calendar.current.dateComponents([.year, .weekOfYear], from: Date())
//                let compLastUpdate = Calendar.current.dateComponents([.year, .weekOfYear], from: DateCreated)
//
//                if((compToday.year! == compLastUpdate.year!) || ((compToday.year! > compLastUpdate.year!) && (compToday.weekOfYear! >= compLastUpdate.weekOfYear!))){
//                    totalWeeks = compToday.weekOfYear! - compLastUpdate.weekOfYear!
//                }else{
//                    totalWeeks = (((compToday.year! - compLastUpdate.year!)*52) + compToday.weekOfYear!) - compLastUpdate.weekOfYear!
//                }

            }

        }


        return totalWeeks
    }

    public func getTallyForPastXweeks(counter: Counter, Weeks: Int) -> Int{
        var tally: Int = 0
        var history: String = counter.history ?? ""

        if(!history.isEmpty){
            history = history.filter{!$0.isNewline && !$0.isWhitespace}
            
            let histArrReversed: [Int] = history.components(separatedBy: ",").reversed().compactMap { Int($0) }

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
        }

        return tally
    }

    private func setupRecords() {
        if counters.count > 0 {
            var sec1 = [records]()
            var sec2 = [records]()
            var sec3 = [records]()
            
            let activeString = activeWeeksSelected ? " ACTIVE " : " "

            for i in 0...counters.count-1 {
                let counter = counters[i]
                let allWeeks = getTotalWeeks(counter: counter, DateCreated: counter.dateCreated, pausedPeriod: counter.pausedPeriod ?? 0)
                
                

                //Total Tally
                let TotalTitle = counter.title
                let TotalWeeks = allWeeks
                let TotalTally = counter.totalSum
                let TotalAverage = (TotalWeeks > 0) ? String((TotalTally-counter.weeklySum)/TotalWeeks) :  "-"
                let TotalDateFrame = "TOTAL OF \(TotalWeeks)\(activeString)WEEKS"
                // "Created Since " + formatterY.string(from: counter.dateCreated) + " | \(TotalWeeks) weeks"
                let TotalRecord = records(title: TotalTitle, weeks: TotalWeeks, average: TotalAverage, tally: String(TotalTally), unit: counter.unit ?? "", dateFrame: TotalDateFrame)
                sec1.append(TotalRecord)

                //Last Week
                
                let LWTitle = counter.title
                let LWWeeks = (allWeeks > 0) ? 1 : 0
                let LWTally = (LWWeeks > 0) ? String(getTallyForPastXweeks(counter: counter, Weeks: LWWeeks)) : "-"
                let LWAverage = (LWTally != "-") ? String(Int(LWTally)!/LWWeeks) :  "-"
                let LWDateFrame = "LAST\(activeString)WEEK"
                    //formatter.string(from: firstDateLastWeek) + "-" + formatterY.string(from: lastDateLastWeek)
                let LWRecord = records(title: LWTitle, weeks: LWWeeks, average: LWAverage, tally: LWTally, unit: counter.unit ?? "", dateFrame: LWDateFrame)
                sec2.append(LWRecord)

                //Last 3 Weeks
                
                let W3Title = counter.title
                let W3Weeks = (allWeeks >= 3) ? 3 : allWeeks
                let W3Tally = (W3Weeks > 0) ? String(getTallyForPastXweeks(counter: counter, Weeks: W3Weeks)) : "-"
                let W3Average = (W3Tally != "-") ? String(Int(W3Tally)!/W3Weeks) :  "-"
                let W3DateFrame = "LAST \(W3Weeks)\(activeString)WEEKS"
                    //formatter.string(from: firstDateLastWeek_3w) + "-" + formatterY.string(from: lastDateLastWeek_3w)
                let W3Record = records(title: W3Title, weeks: W3Weeks, average: W3Average, tally: W3Tally, unit: counter.unit ?? "", dateFrame: W3DateFrame)
                sec3.append(W3Record)

            }

            countersRecords = [sec1, sec2, sec3]
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func segmentActionSelected(_ sender: UISegmentedControl) {
        tableView.reloadData()
        
    }
    
    @IBAction func activeBtnAction(_ sender: UIBarButtonItem) {
        if(activeWeeksSelected == false){
            activeWeeksSelected = true
            activeWeeksBtn.title = "Measure all weeks"
        }else{
            activeWeeksSelected = false
            activeWeeksBtn.title = "Measure active weeks only"
        }
        
        setupRecords()
        tableView.reloadData()
    }
    
    @IBAction func moreInfoAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Note", message: "1. Average score does not include this week's tally \n2. Active weeks are weeks in which you have worked on your goals", preferredStyle: .alert)


        alert.addAction(UIAlertAction(title: "Oot it!", style: .cancel, handler: nil))
//
             
        present(alert, animated: true)
    }
}

class recordCell: UITableViewCell {
    
    @IBOutlet weak var recordTitle: UILabel!
    @IBOutlet weak var recordDate: UILabel!
    @IBOutlet weak var recordTotal: UILabel!
    @IBOutlet weak var recordAverage: UILabel!
    @IBOutlet weak var recordTotalUnit: UILabel!
    @IBOutlet weak var recordAverageUnit: UILabel!
    
    @IBOutlet weak var ContainerView: UIView!{
        didSet {
//            // Make it card-like
//            ContainerView.layer.cornerRadius = 12
//            ContainerView.layer.borderWidth = 0.3
//            ContainerView.layer.borderColor = UIColor.white.cgColor
        }
    }

    func configureCell(record:records) {
        recordTitle.text = String(record.dateFrame)
        recordDate.text = record.title
        recordTotal.text = record.tally
        recordAverage.text = record.average
        recordTotalUnit.text = record.unit
        recordAverageUnit.text = record.unit + "/week"

    }
    
    
    
}

extension RecordViewController: UITableViewDataSource, UITableViewDelegate{
        // MARK: - Table view data source
            
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return countersRecords[segmentControl.selectedSegmentIndex].count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = "cellRecord"
            
            guard let cellTally = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? recordCell  else {
                   fatalError("The dequeued cell is not an instance of cellRecord.")
             }
            
            let tallyRecord = countersRecords[segmentControl.selectedSegmentIndex][indexPath.row]
            
            cellTally.configureCell(record: tallyRecord)
            

            return cellTally
        }
}
