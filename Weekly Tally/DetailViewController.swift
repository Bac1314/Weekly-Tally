//
//  DetailViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 2/7/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import AVFoundation
import UIKit
import os.log

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scannerView: UIView!
    
    // Navigationbar Properties
    @IBOutlet weak var overviewSegmentStack: UIStackView!
    @IBOutlet weak var editSegmentStack: UIStackView!
    @IBOutlet weak var extraDataStack: UIStackView!
    @IBOutlet weak var over_edit_segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    // Overview Segment Properties
    @IBOutlet weak var counterStepperStack: UIView!
    @IBOutlet weak var counterDaySum: CustomLabel!
    @IBOutlet weak var customOverview: CustomOverviewView!
    @IBOutlet weak var customOverviewTotal: CustomOverviewGraph!
    
    // Edit Segment Properties
    @IBOutlet weak var LargeTitle: UILabel!
    @IBOutlet weak var counterTitle: UITextField!
    @IBOutlet weak var counterWeeklyGoal: UITextField!
    @IBOutlet weak var counterUnit: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var counterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var counterDailyGoal: UILabel!
    @IBOutlet weak var perDayLabel: UILabel!
    @IBOutlet weak var counterPause: CustomButton!
    @IBOutlet weak var startsBtn: UIButton!
    @IBOutlet weak var endsBtn: UIButton!
    @IBOutlet weak var StartDatePicker: UIDatePicker!
    @IBOutlet weak var StartDateOptions: UISegmentedControl!
    @IBOutlet weak var EndDatePicker: UIDatePicker!
    @IBOutlet weak var EndDateOptions: UISegmentedControl!
    @IBOutlet weak var divider: UIView!
    
    // Toolbar Properties
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!

    var segmentOverview: Bool = true //Overview and Edit segment
    var includeWeekends: Bool = true
    var counter: Counter?
    var tempCounter: Counter?
    var activeWeeks: Bool = false
    var centerBarButton: UIBarButtonItem!
    var interaction: UIContextMenuInteraction!
    let formatter = DateFormatter()
    
    
    var pickerChoices: [String] = []
    var pickerView =  UIPickerView()
    var pickerTypeValue =  String()
    var customDate = CustomDate()

    
    // Initiliaze capture session object
    let avCaptureSession = AVCaptureSession()
    let avCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Delegates
        counterTitle.delegate = self
        counterWeeklyGoal.delegate = self
        counterUnit.delegate = self
        interaction = UIContextMenuInteraction(delegate: self)

        self.setupToHideKeyboardOnTapOnView()
    
        // Formatter for date
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        // Update the textfields if counter exist
        if let counter = counter {
            
            tempCounter = Counter(title: counter.title, dailyGoal:counter.dailyGoal, unit: counter.unit, dailySum: counter.dailySum, weeklySum: counter.weeklySum, totalSum: counter.totalSum,  weeklyGoal: counter.weeklyGoal, weekendsIncluded: counter.weekendsIncluded, dateCreated: counter.dateCreated, dateEnds: counter.dateEnds, dateUpdated: counter.dateUpdated, paused: counter.paused, pausedPeriod: counter.pausedPeriod, history: counter.history)
            
            // Setup Edit Segment Values
            setUpEditSegmentValues()
            
            if !FutureState {
                // Setup Overview Segment Values
                setupOverviewSegmentValues()
                
                // Set Overview Segment Values
                setSegmentValues(segmentIndex: 0)
                
                // Setup daily values and method
                setupDailyPickerValues()
                
            }else {
                
                // Set segment to EDIT
                setSegmentValues(segmentIndex: 1)
                
                over_edit_segmentControl.isEnabled = false
                            
            }
            
            
        }else{

            tempCounter = Counter(title: "temp", unit: "", weeklyGoal: 1, weekendsIncluded: includeWeekends)
            
            //Set segment to EDIT
            setSegmentValues(segmentIndex: 1)
            
            over_edit_segmentControl.isEnabled = false
            
            setToolBarButtons()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
//        guard let button = sender as? UIBarButtonItem, button === saveButton else {
//            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
//            return
//        }
            
        if let button = sender as? UIBarButtonItem, button === saveButton {
            if let counter = counter, let tempCounter = tempCounter {
                    
                tempCounter.title = counterTitle.text ?? "No title"
                tempCounter.unit = counterUnit.text ?? "Count"
                tempCounter.weeklyGoal = Int(counterWeeklyGoal.text ?? "0") ?? 0
                tempCounter.weekendsIncluded = includeWeekends
                tempCounter.dailyGoal = tempCounter.getDailyGoal()
                tempCounter.dateUpdated = Date()
                
                //If user changed the start date, reset the records
                if(!(Calendar.current.isDate(tempCounter.dateCreated, inSameDayAs: counter.dateCreated))){
                    
                    tempCounter.dailySum = 0
                    tempCounter.weeklySum = 0
                    tempCounter.totalSum = 0
                    tempCounter.history = ""
                }
                
                self.counter = tempCounter
            }else{

                counter = Counter(title: counterTitle.text ?? "", unit: counterUnit.text ?? "", weeklyGoal: Int(counterWeeklyGoal.text ?? "0") ?? 0, weekendsIncluded: includeWeekends)

                counter?.dateCreated = tempCounter?.dateCreated ?? Date()
                counter?.dateEnds = tempCounter?.dateEnds

            }
        }else if let identifier = segue.identifier, identifier == "ShareItem" {
            
            guard let navVC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination on: \(segue.destination)")
            }
            guard let shareViewController = navVC.topViewController as? ShareViewController else{
                fatalError("Unexpected destination on: \(segue.destination)")
            }
            
            shareViewController.counter = counter
            
        }else if let identifier = segue.identifier, identifier == "unwindIdentifier", let _ = segue.destination as? CounterTableViewController, let counter = counter, counter.unit == "delete" {
            //Delete the counter, no other steps necessary
        }else{
                print("NOTHING")
        }


    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if let tempCounter = tempCounter {
            if activeWeeks {
                activeWeeks = false
                
                // SETUP TOTAL PROGRESS
                let allWeeks = CustomTallyCounter().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: 0, activeWeeksSelected: false)
                
                
                let labelTitleTOT = "TOTAL WEEKS"
                let labelSubtitleTOT = "Tally of \(Int(allWeeks)) week(s)"
                let labelRightScoreTOT = (allWeeks > 0) ? String(Int(Float(tempCounter.totalSum)/Float(allWeeks))) :  "-"
                
                customOverviewTotal.overview_data?.title = labelTitleTOT
                customOverviewTotal.overview_data?.subtitle = labelSubtitleTOT
                customOverviewTotal.overview_data?.rightSub = labelRightScoreTOT
                
                customOverviewTotal.history_data = CustomTallyCounter().getListOfWeekTallies(counter: tempCounter, activeWeeksSelected: activeWeeks)
                
                
            } else {
                activeWeeks = true
                
                // SETUP TOTAL PROGRESS
                let allWeeks = CustomTallyCounter().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: 0, activeWeeksSelected: true)
                
                
                let labelTitleTOT = "ACTIVE WEEKS"
                let labelSubtitleTOT = "Tally of \(Int(allWeeks)) active week(s)"
                let labelRightScoreTOT = (allWeeks > 0) ? String(Int(Float(tempCounter.totalSum)/allWeeks)) :  "-"
                
                customOverviewTotal.overview_data?.title = labelTitleTOT
                customOverviewTotal.overview_data?.subtitle = labelSubtitleTOT
                customOverviewTotal.overview_data?.rightSub = labelRightScoreTOT
                
                customOverviewTotal.history_data = CustomTallyCounter().getListOfWeekTallies(counter: tempCounter, activeWeeksSelected: activeWeeks)
                
            }
        }

    }

    // MARK: Actions
    @IBAction func includeWeekends(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
         {
         case 0:
            includeWeekends = true
            updateDailyGoal()
         case 1:
            includeWeekends = false
            updateDailyGoal()
         default:
             break
         }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depnending on the style of presentation (modal or push), the view controller needs to be dismissed in two different ways
        let isPresentingInAddCounterMode = presentingViewController is UINavigationController
        
        if isPresentingInAddCounterMode {
            dismiss(animated: true, completion: nil)
        }else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }else {
            fatalError("The DetailViewController is not inside a navigation controller.")
        }
      
    }
    @IBAction func subTrackCount(_ sender: CustomButton) {

         if let tempCounter = tempCounter {

            if tempCounter.dailySum > 0 {
                tempCounter.dailySum -= 1
                tempCounter.weeklySum -= 1
                tempCounter.totalSum -= 1
            
                counterDaySum.text = String(tempCounter.dailySum)
                tempCounter.dateUpdated = Date()
                
                updateOverviewSegmentValues()
          }
            
        }
    
    }
    @IBAction func addTrackCount(_ sender: CustomButton) {
        
        if let tempCounter = tempCounter {

            if tempCounter.dailySum >= 0 {
                tempCounter.dailySum += 1
                tempCounter.weeklySum += 1
                tempCounter.totalSum += 1
                
                counterDaySum.text = String(tempCounter.dailySum)
                tempCounter.dateUpdated = Date()
                
                updateOverviewSegmentValues()
            }

        }
    }
    
    @IBAction func pauseTabbed(_ sender: CustomButton) {

         if let tempCounter = tempCounter {
            
            if let isPaused = tempCounter.paused, isPaused == true {
                
                //Check if counter has ended
                if (tempCounter.dateEnds == nil || Date() < tempCounter.dateEnds!) {
                    
                    tempCounter.paused = false
                    counterPause.setTitle("ARCHIVE", for: .normal)
                    tempCounter.pausedPeriod = Int(Date().timeIntervalSince1970 - tempCounter.dateUpdated.timeIntervalSince1970) + (tempCounter.pausedPeriod ?? 0)
                    tempCounter.dateUpdated = Date()
                    counterPause.backgroundColor = UIColor.lightGray
                }else {
                    //Counter has cended has ended
                
                    let alert = UIAlertController(title: "Change the end date", message: "This tally has already ended, please change or remove the end date", preferredStyle: .alert)


                    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
//                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
//                        self.counter?.unit = "delete"
//                        self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
//                    }))
                         
                    
                    present(alert, animated: true)
                }

            }else{
                tempCounter.paused = true
                counterPause.setTitle("UNARCHIVE", for: .normal)
                tempCounter.dateUpdated = Date()
                counterPause.backgroundColor = self.view.tintColor
            }
 
        }
        
    }
    
    
    @IBAction func startBtnAction(_ sender: Any) {
        if(StartDatePicker.isHidden == true){
            EndDatePicker.isHidden = true
            EndDateOptions.isHidden = true
            
            if let tempCounter = tempCounter {
                
                //If user edit this date, they will lose all previous data
                if let counter = counter, counter.totalSum > 0{
                    let alert = UIAlertController(title: "Continue?", message: "Changing the start date will clear your current records", preferredStyle: .alert)


                       alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                       alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                           self.StartDateOptions.isHidden = false
                           self.StartDatePicker.isHidden = false
                           self.StartDatePicker.date = tempCounter.dateCreated
                           self.StartDatePicker.minimumDate = Date()
                        
                            if(Calendar.current.isDate(tempCounter.dateCreated, inSameDayAs: Date())){
                                self.StartDateOptions.selectedSegmentIndex = 0
                            }else {
                                self.StartDateOptions.selectedSegmentIndex = 2
                            }
                           
                       }))
                            
                       present(alert, animated: true)
                }else{
                    StartDateOptions.isHidden = false
                    StartDatePicker.isHidden = false
                    StartDatePicker.date = tempCounter.dateCreated
                    StartDatePicker.minimumDate = Date()
                    
                    if(Calendar.current.isDate(tempCounter.dateCreated, inSameDayAs: Date())){
                        StartDateOptions.selectedSegmentIndex = 0
                    }else {
                        StartDateOptions.selectedSegmentIndex = 2
                    }
                    
                }
   
                

                
            }else {
                StartDateOptions.isHidden = false
                StartDatePicker.isHidden = false
                StartDatePicker.minimumDate = Date()
            }
        }else{
            StartDatePicker.isHidden = true
            StartDateOptions.isHidden = true
        }
        
        

    }
    
    @IBAction func endBtnAction(_ sender: Any) {
        
        if(EndDatePicker.isHidden == true){
            StartDatePicker.isHidden = true
            StartDateOptions.isHidden = true
            
            EndDatePicker.isHidden = false
            EndDateOptions.isHidden = false
            
            
            //Update minimum end date
             if let tempCounter = tempCounter {
                EndDatePicker.minimumDate = customDate.getLastDayOfNextWeek(customDate: tempCounter.dateCreated)
                endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
                endsBtn.setTitleColor(.label, for: .normal)
                
                tempCounter.dateEnds = EndDatePicker.date
            }

            //Update the options segments
             if let tempCounter = tempCounter, tempCounter.dateEnds != nil {
                
                //Using Date() instead of advance because we will never need to see the end date on today, so it will go to custom option
                let nextWeek = EndDatePicker.minimumDate ?? Date()
                let nextMonthPre = Calendar.current.date(byAdding: .month, value: 1, to: tempCounter.dateCreated) ?? Date()
                let nextMonth = customDate.getLastDayOfWeek(customDate: nextMonthPre) ?? Date()
                
                if (Calendar.current.isDate(EndDatePicker.date, inSameDayAs: nextWeek)){
                    EndDateOptions.selectedSegmentIndex = 0
                }else if (Calendar.current.isDate(EndDatePicker.date, inSameDayAs: nextMonth)){
                    EndDateOptions.selectedSegmentIndex = 1
                }else {
                    EndDateOptions.selectedSegmentIndex = 2
                }
             }
            
        }else{
            EndDatePicker.isHidden = true
            EndDateOptions.isHidden = true

        }

    }

    @IBAction func StartOptionsAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            StartDatePicker.setDate(Date(), animated: true)
            tempCounter?.dateCreated = Date()
//            startsBtn.setTitle(formatter.string(from: StartDatePicker.date), for: .normal)
            startsBtn.setTitle("today", for: .normal)

        case 1:
           if let tempCounter = tempCounter {
                tempCounter.dateCreated = StartDatePicker.date
                let nextWeek = customDate.getFirstDayOfNextWeek(customDate: tempCounter.dateCreated)
            
                StartDatePicker.setDate(nextWeek, animated: true)
                tempCounter.dateCreated = nextWeek
                startsBtn.setTitle(formatter.string(from: StartDatePicker.date), for: .normal)
            }
        case 2:
            StartDatePicker.setDate(Date(), animated: true)
            tempCounter?.dateCreated = Date()
            startsBtn.setTitle(formatter.string(from: StartDatePicker.date), for: .normal)
        
        default:
            print("something")
          
        }
    }
    
    @IBAction func EndOptionsAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:

            EndDatePicker.setDate(EndDatePicker.minimumDate ?? Date().advanced(by: 604800), animated: true)
            endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)

        case 1:

            let startDate = tempCounter?.dateCreated ?? Date()
            
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate.advanced(by: 2.628e+6)
            let lastDayNextMonthWK = customDate.getLastDayOfWeek(customDate: nextMonth)
                        
            EndDatePicker.setDate(lastDayNextMonthWK ?? startDate.advanced(by: 2.628e+6), animated: true)
            endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
            
        case 2:
            EndDatePicker.setDate(EndDatePicker.minimumDate ?? Date().advanced(by: 604800), animated: true)
            endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
        
        default:
            print("something")
          
        }
    }
    
    @IBAction func StartDatePickerAction(_ sender: Any) {
        //Set Start Date

        startsBtn.setTitle(formatter.string(from: StartDatePicker.date), for: .normal)
        
        if let tempCounter = tempCounter {
            
            let nextWeek = customDate.getFirstDayOfNextWeek(customDate: tempCounter.dateCreated)
            tempCounter.dateCreated = StartDatePicker.date
            
            //Update the segment
            if(Calendar.current.isDate(tempCounter.dateCreated, inSameDayAs: Date())){
                startsBtn.setTitle("today", for: .normal)
                StartDateOptions.selectedSegmentIndex = 0
            }else if(Calendar.current.isDate(tempCounter.dateCreated, inSameDayAs: nextWeek)){
                StartDateOptions.selectedSegmentIndex = 1
            }else{
                StartDateOptions.selectedSegmentIndex = 2
            }
            
            //If dateEnds is in the same week as started, update it
            if(tempCounter.dateEnds != nil && (Calendar.current.isDate(tempCounter.dateCreated, equalTo: tempCounter.dateEnds! , toGranularity: .weekOfYear)) && EndDateOptions.selectedSegmentIndex == 1){
                
                let lastDayNextWK = customDate.getLastDayOfNextWeek(customDate: tempCounter.dateCreated)
                            
                EndDatePicker.minimumDate = lastDayNextWK
                endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
                endsBtn.setTitleColor(.label, for: .normal)
                
                tempCounter.dateEnds = EndDatePicker.date

            }else if(tempCounter.dateEnds != nil && tempCounter.dateCreated >= tempCounter.dateEnds!){

                tempCounter.dateEnds = nil
                endsBtn.setTitle("(optional)", for: .normal)
                endsBtn.setTitleColor(.placeholderText, for: .normal)
            }
          
        }
    
    }
    
    @IBAction func EndDatePickerAction(_ sender: Any) {
        //Set End Date
        endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
        
        if let tempCounter = tempCounter {
            tempCounter.dateEnds = EndDatePicker.date
            
            //Update the segment
            guard let endDate = tempCounter.dateEnds else {
                os_log("no end date", log: OSLog.default, type: .debug)
                 return
            }
            
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: tempCounter.dateCreated) ?? tempCounter.dateCreated.advanced(by: 2.628e+6)
            let lastDayNextMonthWK = customDate.getLastDayOfWeek(customDate: nextMonth)
            
            if(Calendar.current.isDate(endDate, inSameDayAs: EndDatePicker.minimumDate ?? Date())){
           
                EndDateOptions.selectedSegmentIndex = 0
            }else if(Calendar.current.isDate(endDate, inSameDayAs: lastDayNextMonthWK ?? tempCounter.dateCreated.advanced(by: 2.628e+6))) {
                EndDateOptions.selectedSegmentIndex = 1
            }else {
                EndDateOptions.selectedSegmentIndex = 2
            }
        }
    }
    
    
    @IBAction func StartClearAction(_ sender: Any) {
        StartDatePicker.isHidden = true
        StartDateOptions.isHidden = true
        
        if let tempCounter = tempCounter {
            tempCounter.dateCreated = counter?.dateCreated ?? Date()
 
            startsBtn.setTitle(Calendar.current.isDateInToday(tempCounter.dateCreated) ? "today" : formatter.string(from: tempCounter.dateCreated), for: .normal)
            
        }else{
            startsBtn.setTitle("today", for: .normal)
        }
        
    }
    
    @IBAction func EndClearAction(_ sender: Any) {
        EndDatePicker.isHidden = true
        EndDateOptions.isHidden = true
        
        if(tempCounter != nil && counter != nil) {
            tempCounter?.dateEnds = nil
        }
        endsBtn.setTitle("(optional)", for: .normal)
        endsBtn.setTitleColor(.placeholderText, for: .normal)
    }
    
  
    @IBAction func segmentOverEditAction(_ sender: UISegmentedControl) {
        
        setSegmentValues(segmentIndex: sender.selectedSegmentIndex)
    }
    

    
    @IBAction func deleteAction(_ sender: Any) {
        let alert = UIAlertController(title: "Delete this tally", message: nil, preferredStyle: .actionSheet)


        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
            self.counter?.unit = "delete"
            self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
        }))
             
        
        present(alert, animated: true)
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
    }
    
    
    @objc func dailyPickerTapped(_ sender: UITapGestureRecognizer) {
        if let tempCounter = tempCounter {
            guard let tempDaySum = Int(counterDaySum.text ?? "-1"), tempDaySum != -1 else {
                fatalError("counterDaySum.text is nil")
            }
            alertUIPickerBox(title: tempCounter.title)
        }
    }
    
    @objc func addNewTallyQR() {
        
//        do {
//            try scanQRCodeCamera()
//
//            editSegmentStack.isHidden = true
//            LargeTitle.isHidden = true
//        }catch {
//            print("error scanning")
//        }
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Calls after textfield resign first responder
        updateDailyGoal()
        
        // Update navigation title based on all the textfields
        if(counterTitle.text?.isEmpty == true && counterWeeklyGoal.text?.isEmpty == true && counterUnit.text?.isEmpty == true){
            LargeTitle.text = "New Weekly Goal"
        }
        
        if(counterTitle.text?.isEmpty == false && counterTitle.text != LargeTitle.text){
            LargeTitle.text = counterTitle.text
        }
        
        if(counterTitle.text?.isEmpty == true && counterWeeklyGoal.text?.isEmpty == false){
            counterTitle.text = "\(counterWeeklyGoal.text ?? "") per week"
            LargeTitle.text = counterTitle.text
        }
        
        if(counterUnit.text?.isEmpty == false && counterTitle.text == "\(counterWeeklyGoal.text ?? "") per week"){
            counterTitle.text = "\(counterWeeklyGoal.text ?? "") \(counterUnit.text ?? "unit") per week"
            LargeTitle.text = counterTitle.text
        }
        
        if(!(counterTitle.text?.isEmpty ?? false) && !(counterWeeklyGoal.text?.isEmpty ?? false)){
           saveButton.isEnabled = true
        }
    
    }
    
    
    // MARK: Private functions
    private func setSegmentValues(segmentIndex: Int){
        over_edit_segmentControl.selectedSegmentIndex = segmentIndex

        // Scroll to top
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
        
        if(segmentIndex == 0){
            overviewSegmentStack.isHidden = false
            editSegmentStack.isHidden = true
            extraDataStack.isHidden = true
        
        }else{
            overviewSegmentStack.isHidden = true
            editSegmentStack.isHidden = false
            extraDataStack.isHidden = false
            counterPause.isHidden = counter == nil || FutureState == true ? true : false
            
            updateDailyGoal()
        }
    }
    
    
    private func setupOverviewSegmentValues(){
        
        if let _ = counter, let tempCounter = tempCounter{
            
            // SETUP STEPPER PROGRESS
            counterDaySum.text = String(tempCounter.dailySum)
            
            
            // SETUP WEEKLY PROGRESS
            let fractionDone = Float(tempCounter.weeklySum)/Float(tempCounter.weeklyGoal)
            let percentage = String(Int(fractionDone * 100)) + "%"
            
            let labelTitle = "CURRENT WEEK"
            let labelSubtitle = "\(tempCounter.weeklyGoal) \(tempCounter.unit ?? "unit") per week"

            let labelLeftTitle = "Tally"
            let labelLeftScore = String(tempCounter.weeklySum)
            let labelLeftScoreUnit = tempCounter.unit ?? ""
            
            let labelRightTitle = "Progress"
            let labelRightScore = percentage
            let labelRightScoreUnit = "completed"

            let aOverview = overview(title: labelTitle, subtitle: labelSubtitle, leftTitle: labelLeftTitle, leftSub: labelLeftScore, leftUnit: labelLeftScoreUnit, rightTitle: labelRightTitle, rightSub: labelRightScore, rightUnit: labelRightScoreUnit)
            
            customOverview.overview_data = aOverview
//            customOverview.setupData()
            
            // SETUP TOTAL PROGRESS
             let allWeeks = CustomTallyCounter().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: 0, activeWeeksSelected: false)


             let labelTitleTOT = "TOTAL WEEKS"
             let labelSubtitleTOT = "Tally of \(Int(allWeeks)) week(s)"

             let labelLeftTitleTOT = "Tally"
             let labelLeftScoreTOT = String(tempCounter.totalSum)
             let labelLeftScoreUnitTOT = tempCounter.unit ?? ""

             let labelRightTitleTOT = "Average"
             let labelRightScoreTOT = (allWeeks >= 1) ? String(Int(Float(tempCounter.totalSum)/allWeeks)) :  String(Int(Float(tempCounter.totalSum)))
             let labelRightScoreUnitTOT = "\(tempCounter.unit ?? "")/week"


             let aOverviewTOT = overview(title: labelTitleTOT, subtitle: labelSubtitleTOT, leftTitle: labelLeftTitleTOT, leftSub: labelLeftScoreTOT, leftUnit: labelLeftScoreUnitTOT, rightTitle: labelRightTitleTOT, rightSub: labelRightScoreTOT, rightUnit: labelRightScoreUnitTOT)

             customOverviewTotal.overview_data = aOverviewTOT
             customOverviewTotal.history_data = CustomTallyCounter().getListOfWeekTallies(counter: tempCounter, activeWeeksSelected: activeWeeks)
//             customOverviewTotal.setupData()
            
        }
    }
    
    private func updateOverviewSegmentValues(){
        if let _ = counter, let tempCounter = tempCounter{
            
            let allWeeks = CustomTallyCounter().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: 0, activeWeeksSelected: false)
            
            // Update This Week values
            let fractionDone = Float(tempCounter.weeklySum)/Float(tempCounter.weeklyGoal)
            let percentage = String(Int(fractionDone * 100)) + "%"
            let labelRightScoreTOT = (allWeeks > 0) ? String(Int(Float(tempCounter.totalSum)/allWeeks)) :  "-"
            
            customOverview.overview_data?.leftSub = String(tempCounter.weeklySum)
            customOverview.overview_data?.rightSub = percentage
            
            // Update Total Tally Values
            customOverviewTotal.overview_data?.leftSub = String(tempCounter.totalSum)
            customOverviewTotal.overview_data?.rightSub = labelRightScoreTOT
        }
    }


    private func setUpEditSegmentValues(){
        if let counter = counter {
            
            // Set the Edit Segment values
            LargeTitle.text = counter.title
            counterTitle.text = counter.title
            counterWeeklyGoal.text = String(counter.weeklyGoal)
            counterUnit.text = counter.unit
            includeWeekends = counter.weekendsIncluded
            
            if (!includeWeekends){
                counterSegmentedControl.selectedSegmentIndex = 1
                includeWeekends = false
            }
            
            startsBtn.setTitle(formatter.string(from: counter.dateCreated), for: .normal)
            
            if(counter.dateEnds != nil){
                endsBtn.setTitle(formatter.string(from: counter.dateEnds!), for: .normal)
                endsBtn.setTitleColor(.label, for: .normal)
            }
            
            if(counter.paused == true){
                counterPause.setTitle("UNARCHIVE", for: .normal)
                counterPause.backgroundColor = self.view.tintColor
            }
        }
    }
    
    private func updateDailyGoal(){
            
        let weeklyGoal = counterWeeklyGoal.text ?? ""
        if(!weeklyGoal.isEmpty){
            let weeklyValue = Int(counterWeeklyGoal.text ?? "0") ?? 0
            var dailyValue = Int(round(Double(weeklyValue)/5.0))
            if(includeWeekends) {
                dailyValue = Int(round(Double(weeklyValue)/7.0))
            }
            
            if(dailyValue == 0){
                dailyValue = 1
            }
            
            let unit = counterUnit.text ?? ""
            counterDailyGoal.text = "\(dailyValue) \(unit)"
            
            divider.isHidden = false
            counterDailyGoal.isHidden = false
            perDayLabel.isHidden = false

        }else{
            divider.isHidden = true
            counterDailyGoal.isHidden = true
            perDayLabel.isHidden = true
        }
    }
    
    private func setupDailyPickerValues(){
        if let tempCounter = tempCounter {
            let weeklyGoal = tempCounter.weeklyGoal
            if weeklyGoal < 10 {
                for i in 0...15{
                    pickerChoices.append(String(i))
                }
            }else {
                for i in 0...15{
                    if i==0 {
                        pickerChoices.append("0")
                    }else{
                        let newValue: String = String(Int(weeklyGoal/10)*i)
                        pickerChoices.append(newValue)
                    }
                }
            }

        }
        
        //Setup Method for tapp
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.dailyPickerTapped(_:)))
        counterDaySum.isUserInteractionEnabled = true
        counterDaySum.addGestureRecognizer(labelTap)
    }
    
    private func alertUIPickerBox(title: String){
    
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 85)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 85))
//        pickerView.selectRow(2, inComponent: 0, animated: true)
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)

       
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        
        alertController.setValue(vc, forKey: "contentViewController")
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { (UIAlertAction) in
            
            if let tempCounter = self.tempCounter {
                
                self.pickerTypeValue = self.pickerTypeValue.isEmpty ? "0" : self.pickerTypeValue
                self.counterDaySum.text = self.pickerTypeValue

                let difference = (Int(self.pickerTypeValue) ?? 0) - tempCounter.dailySum
                       
                tempCounter.dailySum = Int(self.pickerTypeValue) ?? tempCounter.dailySum
                tempCounter.weeklySum = tempCounter.weeklySum + difference
                tempCounter.totalSum = tempCounter.totalSum + difference
                
                self.updateOverviewSegmentValues()
            }
            
   
            
        }))
        
        present(alertController, animated: true)
    }
    
    private func setToolBarButtons(){
        // Set toolbar scan to add a Tally through QR code
        let addScanBtn = UIButton(type: .custom)

        addScanBtn.setTitle("  hold to scan", for: .normal)
        addScanBtn.setTitleColor(view.tintColor, for: .normal)
        addScanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addScanBtn.setImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
//        addScanBtn.addTarget(self, action: #selector(addNewTallyQR), for: .touchUpInside)
        addScanBtn.sizeToFit()
        
        addScanBtn.addInteraction(interaction)
        
        centerBarButton = UIBarButtonItem(customView: addScanBtn)


        if (centerBarButton == nil) {
            centerBarButton = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(addNewTallyQR))
        }

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, centerBarButton, spacer]
    }
    
    
    
    
    func setupTallyByQRCode(counterString: String){
        
        // Show and hide views 
        LargeTitle.isHidden = false
        editSegmentStack.isHidden = false
        scannerView.isHidden = true
        centerBarButton.isEnabled = true
    

        // Decode it
        if let jsonData = counterString.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            
            do {
                let newcounter = try decoder.decode(Counter.self, from: jsonData)
                
                // Set the Edit Segment values
                LargeTitle.text = newcounter.title
                counterTitle.text = newcounter.title
                counterWeeklyGoal.text = String(newcounter.weeklyGoal)
                counterUnit.text = newcounter.unit
                includeWeekends = newcounter.weekendsIncluded
                
                if (!includeWeekends){
                    counterSegmentedControl.selectedSegmentIndex = 1
                    includeWeekends = false
                }
                
 
                // Set the start date if it is greater or equal to today else set it to today
                if newcounter.dateCreated > Date() || Calendar.current.isDateInToday(newcounter.dateCreated){
                    tempCounter?.dateCreated = newcounter.dateCreated
                    startsBtn.setTitle(formatter.string(from: newcounter.dateCreated), for: .normal)
                    
                    if let endDate = newcounter.dateEnds {
                        endsBtn.setTitle(formatter.string(from: endDate), for: .normal)
                        endsBtn.setTitleColor(.label, for: .normal)
                    }
                }else{
                    tempCounter?.dateCreated = Date()
                    startsBtn.setTitle(formatter.string(from: Date()), for: .normal)
                  
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
    }

}

extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        pickerTypeValue = pickerChoices[row]
    }
    
    
}

extension DetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(
          identifier: nil,
          previewProvider: nil,
          actionProvider: { _ in
            let cameraAction = self.makeCameraAction()
            let folderAction = self.makeFolderAction()
            
            let children = [cameraAction, folderAction]
            return UIMenu(title: "", children: children)
        })
        
    }
    
    func makeCameraAction() -> UIAction {
       // Set attribtes
        let actionAttr = UIMenuElement.Attributes.init()
        
        // Set images
        let image = UIImage(systemName: "camera")
        
        // Return actions
        return UIAction(
            title: "use camera",
            image: image,
            identifier: nil,
            attributes: actionAttr) {_ in
                do {
                    try self.scanQRCodeCamera()
                    
                    self.editSegmentStack.isHidden = true
                    self.LargeTitle.isHidden = true
                }catch {
                    print("error scanning")
                }
        }
    }
    
    func makeFolderAction() -> UIAction {
       // Set attribtes
        let actionAttr = UIMenuElement.Attributes.init()
        
        // Set images
        let image = UIImage(systemName: "folder")
        
        // Return actions
        return UIAction(
            title: "image library",
            image: image,
            identifier: nil,
            attributes: actionAttr) {_ in
                   // UIImagePickerController is a view controller that lets a user pick media from their photo library.
                let imagePickerController = UIImagePickerController()
                
                // Only allow photos to be picked, not taken.
                imagePickerController.sourceType = .photoLibrary
                
                // Make sure ViewController is notified when the user picks an image.
                imagePickerController.delegate = self
                
                self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,AVCaptureMetadataOutputObjectsDelegate {
    
    func scanQRCodeCamera() throws {
        
        scannerView.isHidden = false
        
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print ("no camera boyy")
            throw error.noCameraAvailable
        }
        
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            print ("failed to init camera")
            throw error.videoInputInitFail
        }
        
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main )
        
        // Add input and output
        if avCaptureSession.inputs.count == 0 {
            avCaptureSession.addInput(avCaptureInput)
        }
        
        if avCaptureSession.outputs.count == 0 {
            avCaptureSession.addOutput(avCaptureMetadataOutput)
            avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
        
        
        // Initialize video preview
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = scannerView.layer.bounds
        scannerView.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        self.avCaptureSession.startRunning()
    }
    

//    func scanQRCodeLibrary(_ picker: UIImagePickerController,
//                           didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
//            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
//                                      context: nil,
//                                      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
//            let ciImage = CIImage(image: pickedImage),
//            let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else { return }
//
//        let qrCodeLink = features.reduce("") { $0 + ($1.messageString ?? "") }
//
//        print(qrCodeLink)//Your result from QR Code
//    }
    
     func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
          
          // Check if the metadataObjects array is contains at least one object.
          if metadataObjects.count == 0 {
              return
          }
          
          if avCaptureSession.isRunning {
              DispatchQueue.global().async {
                  self.avCaptureSession.stopRunning()
              }
          }
          
          // Get the metadata object.
          let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
          
          if metadataObj.type == AVMetadataObject.ObjectType.qr {
              if let outputString = metadataObj.stringValue {
                  DispatchQueue.main.async {
                      self.setupTallyByQRCode(counterString: outputString)
                  }
              }
          }
      }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let qrcodeImg = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            var qrCodeMessage=""
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeMessage += feature.messageString!
            }
            
            if qrCodeMessage=="" {
                print("nothing")
            }else{
                self.setupTallyByQRCode(counterString: qrCodeMessage)
            }
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }

}


extension UIViewController
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}



extension UIImage {
    convenience init(view: UIView) {
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        self.init(cgImage: image.cgImage!)
    }
}
