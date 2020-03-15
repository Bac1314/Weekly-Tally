//
//  DetailViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 2/7/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit
import os.log

class DetailViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    // Navigationbar Properties
    @IBOutlet weak var overviewSegmentStack: UIStackView!
    @IBOutlet weak var editSegmentStack: UIStackView!
    @IBOutlet weak var over_edit_segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    // Overview Segment Properties
    @IBOutlet weak var counterStepperStack: UIView!
    @IBOutlet weak var counterDaySum: CustomLabel!
    @IBOutlet weak var recordView: CustomOverviewView!
    
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
    @IBOutlet weak var EndDatePicker: UIDatePicker!
    @IBOutlet weak var divider: UIView!
    
    // Toolbar Properties
    @IBOutlet weak var challengeBtn: UIBarButtonItem!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!

    var segmentOverview: Bool = true //Overview and Edit segment
    var includeWeekends: Bool = true
    var counter: Counter?
    var tempCounter: Counter?
    let formatter = DateFormatter()
    
    var pickerChoices: [String] = []
    var pickerView =  UIPickerView()
    var pickerTypeValue =  String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        counterTitle.delegate = self
        counterWeeklyGoal.delegate = self
        counterUnit.delegate = self
        self.setupToHideKeyboardOnTapOnView()

        //Formatter for date
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        //Update the textfields if counter exist
        if let counter = counter {
            
            LargeTitle.text = counter.title
            counterTitle.text = counter.title
            counterWeeklyGoal.text = String(counter.weeklyGoal)
            counterUnit.text = counter.unit
            includeWeekends = counter.weekendsIncluded
            
            if (!includeWeekends){
                counterSegmentedControl.selectedSegmentIndex = 1
                includeWeekends = false
            }
            
            //Set Start Date and/or End Date
            startsBtn.setTitle(formatter.string(from: counter.dateCreated), for: .normal)
            
            if(counter.dateEnds != nil){
                endsBtn.setTitle(formatter.string(from: counter.dateEnds!), for: .normal)
                endsBtn.setTitleColor(.label, for: .normal)
            }
            
            if(counter.paused == true){
                counterPause.setTitle("UNARCHIVE", for: .normal)
                counterPause.backgroundColor = self.view.tintColor
            }
            
            tempCounter = Counter(title: counter.title, dailyGoal:counter.dailyGoal, unit: counter.unit, dailySum: counter.dailySum, weeklySum: counter.weeklySum, totalSum: counter.totalSum,  weeklyGoal: counter.weeklyGoal, weekendsIncluded: counter.weekendsIncluded, dateCreated: counter.dateCreated, dateEnds: counter.dateEnds, dateUpdated: counter.dateUpdated, paused: counter.paused, pausedPeriod: counter.pausedPeriod, history: counter.history)
            
            
            
            //Setup Label Tap for picker values
            setPickerValues()
            setupLabelTap()
            
            //Set segment to Overview
            setSegmentValues(segmentIndex: 0)
            
        }else{

            tempCounter = Counter(title: "temp", unit: "", weeklyGoal: 1, weekendsIncluded: includeWeekends)
            
            //Set segment to EDIT
            setSegmentValues(segmentIndex: 1)
            over_edit_segmentControl.isEnabled = false
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
            if let _ = counter, let tempCounter = tempCounter {

                tempCounter.title = counterTitle.text ?? "No title"
                tempCounter.unit = counterUnit.text ?? "Count"
                tempCounter.weeklyGoal = Int(counterWeeklyGoal.text ?? "0") ?? 0
                tempCounter.weekendsIncluded = includeWeekends
                tempCounter.dailyGoal = tempCounter.getDailyGoal()
                
                tempCounter.dateUpdated = Date()
                
                self.counter = tempCounter
            }else{

                counter = Counter(title: counterTitle.text ?? "", unit: counterUnit.text ?? "", weeklyGoal: Int(counterWeeklyGoal.text ?? "0") ?? 0, weekendsIncluded: includeWeekends)

                counter?.dateCreated = tempCounter?.dateCreated ?? Date()
                counter?.dateEnds = tempCounter?.dateEnds
                
//                if(endsBtn.currentTitle != "(optional)"){
//                    counter?.dateEnds = EndDatePicker.date
//                }
            }
        }else if let identifier = segue.identifier, identifier == "unwindIdentifier", let _ = segue.destination as? CounterTableViewController, let counter = counter, counter.unit == "delete" {
            //Delete the counter, no other steps necessary
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
                
                updateOverviewValues()
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
                
                updateOverviewValues()
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
    
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        if let tempCounter = tempCounter {
            guard let tempDaySum = Int(counterDaySum.text ?? "-1"), tempDaySum != -1 else {
                fatalError("counterDaySum.text is nil")
            }
            alertUIPickerBox(title: tempCounter.title)
        }
    }
    
    func setupLabelTap() {
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        counterDaySum.isUserInteractionEnabled = true
        counterDaySum.addGestureRecognizer(labelTap)
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
    
    @IBAction func deleteAction(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Delete this Tally, '\(counter?.title ?? "Unknown")'", preferredStyle: .alert)


        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.counter?.unit = "delete"
            self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
        }))
             
        
        present(alert, animated: true)
    }
    
    @IBAction func startBtnAction(_ sender: Any) {
        if(StartDatePicker.isHidden == true){
            EndDatePicker.isHidden = true
            
            if let tempCounter = tempCounter {
                //If user edit this date, they will lose all previous data
                
                if let _ = counter {
                    let alert = UIAlertController(title: "Continue?", message: "Changing the start date will clear your current records", preferredStyle: .alert)


                       alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                       alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                           self.StartDatePicker.isHidden = false
                           self.StartDatePicker.date = tempCounter.dateCreated
                           self.StartDatePicker.minimumDate = Date()
                           
                       }))
                            
                       present(alert, animated: true)
                }else{
                    self.StartDatePicker.isHidden = false
                    self.StartDatePicker.date = tempCounter.dateCreated
                    self.StartDatePicker.minimumDate = Date()
                }
   
                

                
            }else {
                StartDatePicker.isHidden = false
                StartDatePicker.minimumDate = Date()
            }
        }else{
            StartDatePicker.isHidden = true
        }
        
        

    }
    
    @IBAction func endBtnAction(_ sender: Any) {
        
        if(EndDatePicker.isHidden == true){
            StartDatePicker.isHidden = true
            EndDatePicker.isHidden = false
            
            let startDate = tempCounter?.dateCreated ?? Date()
            
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: startDate)
            let lastDayNextWK = calendar.date(byAdding: .day, value: 7 + (7-dayOfWeek), to: startDate)
            
            var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: lastDayNextWK ?? Date())
            component.hour = 23
            component.minute = 59
            component.second = 59
                        
            EndDatePicker.minimumDate = Calendar.current.date(from: component) ?? lastDayNextWK
            endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
            endsBtn.setTitleColor(.label, for: .normal)
            
            tempCounter?.dateEnds = EndDatePicker.date
            

        }else{
            EndDatePicker.isHidden = true

        }

    }

    @IBAction func StartDatePickerAction(_ sender: Any) {
        //Set Start Date

        startsBtn.setTitle(formatter.string(from: StartDatePicker.date), for: .normal)
        
        if let tempCounter = tempCounter {
            tempCounter.dateCreated = StartDatePicker.date
            
            //If dateEnds is in the same week as started, update it
            if(tempCounter.dateEnds != nil && Calendar.current.isDate(tempCounter.dateCreated, equalTo: tempCounter.dateEnds! , toGranularity: .weekOfYear)){
                
                let startDate = tempCounter.dateCreated
                
                let calendar = Calendar.current
                let dayOfWeek = calendar.component(.weekday, from: startDate)
                let lastDayNextWK = calendar.date(byAdding: .day, value: 7 + (7-dayOfWeek), to: startDate)
                
                var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: lastDayNextWK ?? Date())
                component.hour = 23
                component.minute = 59
                component.second = 59
                            
                EndDatePicker.minimumDate = Calendar.current.date(from: component) ?? lastDayNextWK
                endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
                endsBtn.setTitleColor(.label, for: .normal)
                
                tempCounter.dateEnds = EndDatePicker.date
                
            }
          
        }
    
    }
    
    @IBAction func EndDatePickerAction(_ sender: Any) {
        //Set End Date
        endsBtn.setTitle(formatter.string(from: EndDatePicker.date), for: .normal)
        
        if let tempCounter = tempCounter {
            tempCounter.dateEnds = EndDatePicker.date
        }
    }
    
    
    @IBAction func StartClearAction(_ sender: Any) {
        if let tempCounter = tempCounter {
            tempCounter.dateCreated = counter?.dateCreated ?? Date()
 
            startsBtn.setTitle(Calendar.current.isDateInToday(tempCounter.dateCreated) ? "today" : formatter.string(from: tempCounter.dateCreated), for: .normal)
            
        }else{
            startsBtn.setTitle("today", for: .normal)
        }
        
    }
    
    @IBAction func EndClearAction(_ sender: Any) {
        if(tempCounter != nil && counter != nil) {
            tempCounter?.dateEnds = nil
        }
        endsBtn.setTitle("(optional)", for: .normal)
        endsBtn.setTitleColor(.placeholderText, for: .normal)
    }
    
  
    @IBAction func segmentOverEditAction(_ sender: UISegmentedControl) {
        
        setSegmentValues(segmentIndex: sender.selectedSegmentIndex)
    }
    
    
    
    // MARK: Private functions
    private func setSegmentValues(segmentIndex: Int){
        over_edit_segmentControl.selectedSegmentIndex = segmentIndex
        
        if(segmentIndex == 0){
            overviewSegmentStack.isHidden = false
            editSegmentStack.isHidden = true
            
            if let tempCounter = tempCounter {
                //Set the values of the counter
                counterDaySum.text = String(tempCounter.dailySum)
            }
            
//            contentView.backgroundColor = UIColor.systemGroupedBackground
        
        }else{
            overviewSegmentStack.isHidden = true
            editSegmentStack.isHidden = false
//            contentView.backgroundColor = UIColor.systemBackground
             
        }
        
        showOrHideOutsideViews()
    }
    
    private func showOrHideOutsideViews(){
        //Show or hide the views outside the two main segment stacks
        if(over_edit_segmentControl.selectedSegmentIndex == 0){
            
            counterStepperStack.isHidden = false
            recordView.isHidden = false
            
            divider.isHidden = true
            counterDailyGoal.isHidden = true
            perDayLabel.isHidden = true
            counterPause.isHidden = true
            saveButton.isEnabled = true
            
            updateOverviewValues()

        }else{
            counterStepperStack.isHidden = true
            recordView.isHidden = true
            
            divider.isHidden = false
            counterDailyGoal.isHidden = false
            perDayLabel.isHidden = false
            counterPause.isHidden = counter == nil ? true : false
            saveButton.isEnabled = true
            
            updateDailyGoal()
        }
    }
    
    private func updateOverviewValues(){
        
        if let _ = counter, let tempCounter = tempCounter{
//            let allWeeks = RecordViewController().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: tempCounter.pausedPeriod ?? 0)
//
//            //Total Tally
//            let TotalAverage = (allWeeks > 0) ? String((tempCounter.totalSum-tempCounter.weeklySum)/allWeeks) :  "-"
  
            recordView.labelTitle.text = "Your weekly goal for this activity"
            recordView.labelSubtitle.text = "\(tempCounter.weeklyGoal) \(tempCounter.unit ?? "unit") per week"

            recordView.labelLeftTitle.text = "THIS WEEK"
            recordView.labelLeftScore.text = String(tempCounter.weeklySum)
            recordView.labelLeftScoreUnit.text = tempCounter.unit ?? ""
            
            recordView.labelRightTitle.text = "TOTAL"
            recordView.labelRightScore.text = String(tempCounter.totalSum)
            recordView.labelRightScoreUnit.text = tempCounter.unit ?? ""
            
            let fractionDone = Float(tempCounter.weeklySum)/Float(tempCounter.weeklyGoal)
            recordView.progressView.setProgress(fractionDone >= 1 ? 1 : fractionDone, animated: true)
            recordView.labelPercentage.text = String(Int(fractionDone * 100)) + "%"
            
            if(fractionDone <= 1){
                recordView.labelPercentDescription.text = "You are \(recordView.labelPercentage.text ?? "0%") done towards your weekly goal"
            }else if(fractionDone > 1 && fractionDone <= 2){
                recordView.labelPercentDescription.text = "You have completed your weekly goal with \(recordView.labelPercentage.text ?? "a total of \(tempCounter.weeklySum)")"
            }else if(fractionDone > 2 && fractionDone < 3){
                recordView.labelPercentDescription.text = "You have more than doubled your weekly goal!"
            }else{
                let exceedPercentage = "\(Int((fractionDone - 1)*100))%"
                recordView.labelPercentDescription.text = "You exceeded your weekly goal by \(exceedPercentage)"
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
    
    private func setPickerValues(){
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
                
                self.updateOverviewValues()
            }
            
   
            
        }))
        
        present(alertController, animated: true)
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
