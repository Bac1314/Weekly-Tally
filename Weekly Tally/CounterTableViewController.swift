//
//  MainTableViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 1/22/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit
import os.log
import AVFoundation
//import Firebase
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

// MARK: Global Properties
var audioPlayer: AVAudioPlayer?

var ArchivedState: Bool = false
var FutureState: Bool = false
let defaults = UserDefaults.standard

// Google Drive instances
let googleDriveService = GTLRDriveService() // for making Google Drive calls
var googleUser: GIDGoogleUser? // for listing user's files only
var uploadFolderID: String?
private var drive: CustomGoogleDrive?

class CounterTableViewController: UITableViewController, UISearchResultsUpdating, customCellDelegate{
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
//    var handle: AuthStateDidChangeListenerHandle?
    
    var counters: [Counter] = []
    var filteredCounters: [Counter] = []
    var countersArchived : [Counter] = []
    var countersFuture : [Counter] = []
    var newCountersEnded : String = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    var AddBtn = UIButton(type: .custom)
    var canEdit : Bool = false
    
    @IBOutlet weak var ArchivedListBtn: UIButton!
    @IBOutlet weak var FutureListBtn: UIButton!
    @IBOutlet weak var ProfileBtn: UIBarButtonItem!
    @IBOutlet weak var EditBtn: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
//            print("Documents Directory: \(documentsPath)")
//        }
        // Set up the search bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tally"
        //        searchController.searchBar.scopeButtonTitles = ["All", "Chocolate"]
        navigationItem.searchController = searchController
        definesPresentationContext = true
        //        navigationItem.rightBarButtonItem = editButtonIte
        
        /***** Configure Google Sign In *****/
        setupGoogleSignIn()
        drive = CustomGoogleDrive(googleDriveService)
        
        //        /* ~~~~~~~~~~ TESTING ~~~~~~~~~~ */
        //        var components = DateComponents()
        //
        //        components.day = 10
        //        components.month = 4
        //        components.year = 2020
        //
        //        let date2 = Calendar.current.date(from: components)!
        //        defaults.set(date2, forKey: "LastRun")
        //        defaults.set(date2, forKey: "LastUpdate")
        //
        //        print("date2 \(date2)")
        //        /* ~~~~~~~~~~ TESTING ~~~~~~~~~~ */
        
        // Load any saved meals, otherwise load sample data
        if let savedCounters = loadCounters(){
            newCountersEnded = ""
            
            
            for counter in savedCounters {
                
                
                if(counter.paused != nil && counter.paused == true){
                    countersArchived += [counter]
                }else if let endDate = counter.dateEnds, endDate < Date(){
                    counter.paused = true
                    countersArchived += [counter]
                    newCountersEnded += "\(counter.title)\n"
                }else if (!(Calendar.current.isDate(counter.dateCreated , inSameDayAs: Date())) && counter.dateCreated > Date()){
                    countersFuture += [counter]
                }else {
                    counters += [counter]
                }
            }
            
        }else{
            loadSampleCounters()
        }
        
        //Update counters dailySum and weeklySum
        updateCounters()
        
        //Set title date
        updateTitle()
        
        //Setup add and edit buttons
        setupToolBarButtons()
        
        //Observe when app willEnterForeground
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(!newCountersEnded.isEmpty){
            //            newCountersEnded = "These following tallies have ended and sent to the archived list\n\n" + newCountersEnded
            
            popUpAlert(title: "The following tallies have ended and sent to the archive list", message: newCountersEnded, buttonTitle: "Got it!")
            
            newCountersEnded = ""
            
            saveCounters()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            // ...
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Four different states: Archive, Future, Search, Normal
        if ArchivedState {
            return countersArchived.count
        }else if FutureState {
            return countersFuture.count
        }
        else if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
            return filteredCounters.count
        }else{
            return counters.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? customCell  else {
            fatalError("The dequeued cell is not an instance of customCell.")
        }
        
        let counter: Counter
        
        if ArchivedState {
            counter = countersArchived[indexPath.row]
        }else if FutureState {
            counter = countersFuture[indexPath.row]
        }else if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
            counter = filteredCounters[indexPath.row]
        }else{
            counter = counters[indexPath.row]
        }
        
        //TESTING
        //                if(counter.title == "Get a nice and firm a$$"){
        //                    counter.history = "250,400,250,300,250,300,160,251,"
        //                }else
        //                    if(counter.title == "250 pushups per week"){
        //                    counter.history = "100,25,0,25,109,150,150,200,201,120,210,"
        //                }
        //                    else if(counter.title == "5 apps per week"){
        //                    counter.history = "9,"
        //                }
        //                print("counter title \(counter.title) - History \(counter.history) - Date \(counter.dateCreated)")
        //
        
        cell.cellCounter = counter
        cell.cellDelegate = self
        
        //Configure the cell...
        cell.cellTitle.text = counter.title
        cell.cellDailyAdd.text = String(counter.dailyGoal)
        cell.cellDailySum.text = String(counter.dailySum)
        cell.cellUnit.text = counter.unit?.uppercased()
        cell.cellWeeklySum?.text = "\(counter.weeklySum)|\(counter.weeklyGoal)"
        cell.cellProgress.progress = Float(counter.weeklySum)/Float(counter.weeklyGoal)
        
        //        if (cell.cellProgress.progress >= 1) {
        //            cell.cellProgress.progressTintColor = .green
        //        }
        
        if ArchivedState {
            
            let today = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
            
            let pausedDays = Calendar.current.dateComponents([.day], from: counter.dateUpdated, to: today).day ?? Int(Date().timeIntervalSince1970 - counter.dateUpdated.timeIntervalSince1970)/(86400)
            
            cell.cellDailySum.text = "ARCHIVED"
            cell.cellUnit.text = "for \(pausedDays) day(s)"
            cell.cellDailySum.font = UIFont.systemFont(ofSize: 20.0)
            cell.ContainerView.alpha = 0.6
            cell.cellBtn.isHidden = true
            cell.cellDailyAdd.isHidden = true
            cell.cellWeeklySum.isHidden = true
            cell.cellWeekLabel.isHidden = true
            cell.cellProgress.isHidden = true
            //            cell.cellUnit.isHidden = true
        }else if FutureState {
            
            let startDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: counter.dateCreated)!
            
            let futureDays =  Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? Int((counter.dateCreated.timeIntervalSince1970 - Date().timeIntervalSince1970)/86400)
            
            cell.cellDailySum.text = "In \(futureDays) day(s)"
            cell.cellUnit.text = "until the start"
            cell.cellDailySum.font = UIFont.systemFont(ofSize: 30.0)
            //            cell.ContainerView.alpha = 0.6
            cell.cellBtn.isHidden = true
            cell.cellDailyAdd.isHidden = true
            cell.cellWeeklySum.isHidden = true
            cell.cellWeekLabel.isHidden = true
            cell.cellProgress.isHidden = true
            
        }else{
            cell.cellDailySum.font = UIFont.systemFont(ofSize: 50.0)
            cell.ContainerView.alpha = 1
            cell.cellBtn.isHidden = false
            cell.cellDailyAdd.isHidden = false
            cell.cellWeeklySum.isHidden = false
            cell.cellWeekLabel.isHidden = false
            cell.cellProgress.isHidden = false
        }
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        //        let counter: Counter
        //
        //        if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
        //           counter = filteredCounters[indexPath.row]
        //        }else{
        //           counter = counters[indexPath.row]
        //        }
        //
        //        if let isPaused = counter.paused, isPaused == true{
        //            return false
        //        }
        return canEdit
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            if ArchivedState {
                countersArchived.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                saveCounters()
            }else if FutureState {
                countersFuture.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                saveCounters()
            }
            else if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
                
                for n in 0...counters.count {
                    if(counters[n].title == filteredCounters[indexPath.row].title){
                        counters.remove(at: n)
                        break
                    }
                }
                
                filteredCounters.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                //                searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
                
                saveCounters()
            }
            else{
                counters.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                saveCounters()
            }
        } else if editingStyle == .insert {
            
            
            
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        if ArchivedState {
            let itemToMove = countersArchived[fromIndexPath.row]
            countersArchived.remove(at: fromIndexPath.row)
            countersArchived.insert(itemToMove, at: to.row)
        }else if FutureState {
            let itemToMove = countersFuture[fromIndexPath.row]
            countersFuture.remove(at: fromIndexPath.row)
            countersFuture.insert(itemToMove, at: to.row)
        }else if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
            let itemToMove = filteredCounters[fromIndexPath.row]
            filteredCounters.remove(at: fromIndexPath.row)
            filteredCounters.insert(itemToMove, at: to.row)
        }else{
            let itemToMove = counters[fromIndexPath.row]
            counters.remove(at: fromIndexPath.row)
            counters.insert(itemToMove, at: to.row)
        }
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // Disable full swipe to delete
    //    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
    //             print("index path of delete: \(indexPath)")
    //             completionHandler(true)
    //         }
    //         let swipeAction = UISwipeActionsConfiguration(actions: [delete])
    //         swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
    //         return swipeAction
    //    }
    
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch(segue.identifier ?? ""){
        case "AddItem":
            os_log("Adding a new counter.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            
            var selectedArray: [Counter]
            if ArchivedState {
                selectedArray = countersArchived
            }else if FutureState {
                selectedArray = countersFuture
            }else if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
                selectedArray = filteredCounters
            }else{
                selectedArray = counters
            }
            
            guard let counterDetailViewController = segue.destination as? DetailViewController else{
                fatalError("Unexpected destination on: \(segue.destination)")
            }
            
            guard let selectedCounterCell = sender as? customCell else{
                fatalError("Unexpected sender: \(sender ?? "error")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCounterCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedCounter = selectedArray[indexPath.row]
            
            counterDetailViewController.counter = selectedCounter
            //            counterDetailViewController.hidesBottomBarWhenPushed = true
            //        case "Records":
            //            guard let counterTotalTableViewController = segue.destination as? RecordViewController else{
            //                      fatalError("Unexpected destination on: \(segue.destination)")
            //            }
            //
            //            counterTotalTableViewController.counters = counters
            //            counterTotalTableViewController.hidesBottomBarWhenPushed = true
            
        case "ShowSlides":
            os_log("Showing slides.", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "error")")
        }
    }
    
    
    // MARK: Private Methods
    private func loadSampleCounters(){
        guard let counter1 = Counter(title: "Learn Java development", unit: "hours", weeklyGoal: 8, weekendsIncluded: true) else {
            fatalError("Unable to instantiate counter 1")
        }
        
        guard let counter2 = Counter(title: "200 pushups per week", unit: "pushups", weeklyGoal: 200, weekendsIncluded: false) else {
            fatalError("Unable to instantiate counter 2")
        }
        
        guard let counter3 = Counter(title: "Run 5 miles", unit: "miles", weeklyGoal: 5, weekendsIncluded: false) else {
            fatalError("Unable to instantiate counter 3")
        }
        
        counters += [counter1, counter2, counter3]
        defaults.set(Date(), forKey: "LastUpdate")
    }
    
    
    private func loadCounters() -> [Counter]?{
        
        if let savedCounters = defaults.object(forKey: "savedCounters") as? Data {
            let decoder = JSONDecoder()
            if let loadedCounters = try? decoder.decode([Counter].self, from: savedCounters) {
                return loadedCounters
            }
        }
        
        return nil
    }
    
    private func saveCounters(){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(counters + countersArchived + countersFuture) {
            defaults.set(encoded, forKey: "savedCounters")
            
        }
    }
    
    
    private func updateTitle() {
        let date = Date()
        let formatter = DateFormatter()
        ////        formatter.dateStyle = .long
        ////        formatter.timeStyle = .none
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        let weekDayString =  formatter.string(from: date)
        
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        navigationItem.title =  "DAY \(dayOfWeek) - \(weekDayString)"
    }
    
    private func filterCounters(for searchText: String) {
        filteredCounters = counters.filter { counter in
            return counter.title.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    private func updateCounters(){
        // Compare updated this week
        // If not the same, then update counters
        
        let today = Date()
        let lastUpdated = defaults.object(forKey: "LastUpdate") as? Date ?? Date()
        
        //Check if NOT in the same week
        if(!(Calendar.current.isDate(lastUpdated, equalTo: today, toGranularity: .weekOfYear))){
            
            let compToday = Calendar.current.dateComponents([.year, .weekOfYear], from: today)
            let compLastUpdate = Calendar.current.dateComponents([.year, .weekOfYear], from: lastUpdated)
            
            var weeksPassed = 0
            
            if((compToday.year! == compLastUpdate.year!) || ((compToday.year! > compLastUpdate.year!) && (compToday.weekOfYear! >= compLastUpdate.weekOfYear!))){
                weeksPassed = compToday.weekOfYear! - compLastUpdate.weekOfYear!
            }else{
                weeksPassed = (((compToday.year! - compLastUpdate.year!)*52) + compToday.weekOfYear!) - compLastUpdate.weekOfYear!
            }
            
            
            //Update counter one-by-one
            for counter in counters {
                if counter.history == nil{
                    counter.history = ""
                }
                
                //Add to history for each weeks passed
                for _ in 1...weeksPassed {
                    counter.history?.append("\(counter.weeklySum),")
                    counter.weeklySum = 0
                }
            }
            
            defaults.set(Date(), forKey: "LastUpdate")
        }
        
        //Update the daily sum if new day
        let lastRunDate = defaults.object(forKey: "LastRun") as? Date ?? Date(timeIntervalSinceReferenceDate: 0)
        
        
        if !Calendar.current.isDateInToday(lastRunDate){
            for counter in counters {
                counter.dailySum = 0
            }
            
            //Save user defaults
            defaults.set(Date(), forKey: "LastRun")
        }
        
        //Save Date
        saveCounters()
    }
    
    private func setupToolBarButtons(){
        
        if ArchivedState || FutureState {
            
            var goBackBarBtn : UIBarButtonItem!
            goBackBarBtn = UIBarButtonItem(title: "Done", style: .plain,target: self, action: #selector(goBackToMain))
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbarItems = [spacer, goBackBarBtn, spacer]
        }
        else {
            AddBtn.setTitle("  New Tally", for: .normal)
            AddBtn.setTitleColor(view.tintColor, for: .normal)
            AddBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            AddBtn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            AddBtn.addTarget(self, action: #selector(addNewTally), for: .touchUpInside)
            AddBtn.sizeToFit()
            
            var leftBarButton: UIBarButtonItem!
            leftBarButton = UIBarButtonItem(customView: AddBtn)
            
            
            if (leftBarButton == nil) {
                leftBarButton = UIBarButtonItem(title: "Add New Tally", style: .plain,target: self, action: #selector(addNewTally))
            }
            
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbarItems = [leftBarButton, spacer]
        }
    }
    
    func didTapButton(_ cellCounter: Counter) {
        //Tapped the add button
        
        //Play sound effect
        let path = Bundle.main.path(forResource: "clickSound.m4a", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            os_log("Couldn't play sound", log: OSLog.default, type: .debug)
            
        }
        
        //TableView Cell Button Tapped
        if let selectedIndex = counters.firstIndex(of: cellCounter){
            
            let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
            cellCounter.weeklySum += cellCounter.dailyGoal
            cellCounter.totalSum += cellCounter.dailyGoal
            cellCounter.dailySum += cellCounter.dailyGoal
            cellCounter.dateUpdated = Date()
            counters[selectedIndexPath.row] = cellCounter
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
            
            //Save counters
            saveCounters()
        }
    }
    
    func scrollToTop(){
        
        if(tableView.numberOfRows(inSection: 0) > 0){
            let topRow = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: topRow, at: .top, animated: true)
        }
    }
    
    func popUpAlert(title: String, message: String, buttonTitle: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK - Searh methods
    func updateSearchResults(for searchController: UISearchController) {
        filterCounters(for: searchController.searchBar.text ?? "")
    }
    
    
    
    // MARK: Actions
    @IBAction func unwindToCounterList(sender: UIStoryboardSegue){
        
        
        if let sourceViewController = sender.source as? DetailViewController, let counter = sourceViewController.counter {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                
                //Update an existing counter
                if ArchivedState {
                    if counter.unit == "delete" {
                        countersArchived.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                    }else if let isPaused = counter.paused, isPaused == false{
                        countersArchived.remove(at: selectedIndexPath.row)
                        
                        if (!(Calendar.current.isDate(counter.dateCreated , inSameDayAs: Date())) && counter.dateCreated > Date()){
                            countersFuture += [counter]
                        }else{
                            counters.insert(counter, at: 0)
                            tableView.deleteRows(at: [selectedIndexPath], with: .automatic)
                        }
                        
                    }else{
                        countersArchived[selectedIndexPath.row] = counter
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                    
                }else if FutureState {
                    if counter.unit == "delete" {
                        countersFuture.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                    }else if (Calendar.current.isDate(counter.dateCreated , inSameDayAs: Date())){
                        countersFuture.remove(at: selectedIndexPath.row)
                        counters.insert(counter, at: 0)
                        tableView.deleteRows(at: [selectedIndexPath], with: .automatic)
                    }else{
                        countersFuture[selectedIndexPath.row] = counter
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                    
                }else if searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) {
                    
                    if counter.unit == "delete" {
                        
                        for n in 0...counters.count {
                            if(counters[n].title == filteredCounters[selectedIndexPath.row].title){
                                counters.remove(at: n)
                                break
                            }
                        }
                        
                        filteredCounters.remove(at: selectedIndexPath.row)
                        
                        tableView.reloadData()
                    }else if let isPaused = counter.paused, isPaused == true{
                        countersArchived += [counter]
                        
                        for n in 0...counters.count {
                            if(counters[n].title == filteredCounters[selectedIndexPath.row].title){
                                counters.remove(at: n)
                                break
                            }
                        }
                        filteredCounters.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                    }else if counter.dateCreated > Date(){
                        countersFuture += [counter]
                        
                        for n in 0...counters.count {
                            if(counters[n].title == filteredCounters[selectedIndexPath.row].title){
                                counters.remove(at: n)
                                break
                            }
                        }
                        
                        filteredCounters.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                        
                        
                    }else{
                        filteredCounters[selectedIndexPath.row] = counter
                        
                        for n in 0...counters.count {
                            if(counters[n].title == filteredCounters[selectedIndexPath.row].title){
                                counters[n] = counter
                                break
                            }
                        }
                        
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                }
                else{
                    
                    if counter.unit == "delete" {
                        counters.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                    }else if let isPaused = counter.paused, isPaused == true{
                        countersArchived += [counter]
                        counters.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                    }else if counter.dateCreated > Date(){
                        countersFuture += [counter]
                        counters.remove(at: selectedIndexPath.row)
                        tableView.reloadData()
                    }else{
                        counters[selectedIndexPath.row] = counter
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                }
                
            }else{
                //Add a new counter to beginning
                if counter.dateCreated > Date(){
                    // Future counter
                    countersFuture += [counter]
                    
                    let startDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: counter.dateCreated)!
                    
                    let futureDays =  Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? Int((counter.dateCreated.timeIntervalSince1970 - Date().timeIntervalSince1970)/86400)
                    
                    let popMessage = "This tally will show up in \(futureDays) day(s)"
                    
                    popUpAlert(title: counter.title, message: popMessage, buttonTitle: "Got it!")
                    
                }else {
                    
                    let newIndexPath = IndexPath(row: 0, section: 0)
                    counters.insert(counter, at: 0)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            }
            
            //Save counters
            saveCounters()
            
        }
        
    }
    
    
    @IBAction func archivedListAction(_ sender: UIButton) {
        if(!ArchivedState){
            // Set the lists states
            ArchivedState = true
            FutureState = false
            
            EditBtn.isEnabled = false
            ProfileBtn.isEnabled = false
            
            ArchivedListBtn.isHidden = true
            FutureListBtn.isHidden = true
            
            // Disable search bar
            searchController.searchBar.isUserInteractionEnabled = false
            searchController.searchBar.alpha = 0.5
            
            navigationItem.title =  "Archived Tallies"
            setupToolBarButtons()
        }
        
        tableView.reloadData()
        scrollToTop()
    }
    
    @IBAction func futureListAction(_ sender: UIButton) {
        
        if(!FutureState){
            // Set the lists states
            FutureState = true
            ArchivedState = false
            
            EditBtn.isEnabled = false
            ProfileBtn.isEnabled = false
            
            ArchivedListBtn.isHidden = true
            FutureListBtn.isHidden = true
            
            // Disable search bar
            searchController.searchBar.isUserInteractionEnabled = false
            searchController.searchBar.alpha = 0.5
            
            navigationItem.title =  "Upcoming Tallies"
            setupToolBarButtons()
        }
        
        tableView.reloadData()
        scrollToTop()
    }
    
    @IBAction func EditAction(_ sender: UIBarButtonItem) {
        
        canEdit = canEdit ? false : true
        tableView.reloadData()
        
        if(tableView.isEditing == true)
        {
            
            // Disable Editing first
            canEdit = false
            tableView.reloadData()
            
            // Set Editing false
            tableView.setEditing(false, animated: true)
            searchController.searchBar.isUserInteractionEnabled = true
            searchController.searchBar.alpha = 1
            EditBtn.title = "Edit"
            AddBtn.isEnabled = true
            AddBtn.alpha = 1
            ProfileBtn.isEnabled = true
            
            //            saveCounters()
        }
        else
        {
            // Enable Editing first
            canEdit = true
            tableView.reloadData()
            
            // Set Editing Mode
            tableView.setEditing(true, animated: true)
            searchController.searchBar.isUserInteractionEnabled = false
            searchController.searchBar.alpha = 0.5
            EditBtn.title = "Done"
            AddBtn.isEnabled = false
            AddBtn.alpha = 0.5
            ProfileBtn.isEnabled = false
            
        }
        
    }
    
    @IBAction func profileAction(_ sender: UIBarButtonItem) {
        //        let ac = UIAlertController(title: "Not available yet", message: "This feature is currently unavailable", preferredStyle: .alert)
        //        ac.addAction(UIAlertAction(title: "OK", style: .default))
        //        present(ac, animated: true)
        
        
//        // Start Google's OAuth authentication flow
//        GIDSignIn.sharedInstance()?.signIn()
        
//        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
//            let testFilePath = documentsDir.appendingPathComponent("airport.jpeg").path
//            drive?.uploadFile("weekly_tally_data", filePath: testFilePath, MIMEType: "image/jpeg") { (fileID, error) in
//                print("Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
//            }
//        }
        
          self.performSegue(withIdentifier: "ShowSlides", sender: self)
        
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(counters + countersArchived + countersFuture) {
//            defaults.set(encoded, forKey: "savedCounters")
//            
//            
//            let fileName = Bundle.main.bundleIdentifier!
//            let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
//            let preferences = library.appendingPathComponent("Preferences")
//            let userDefaultsPlistURL = preferences.appendingPathComponent(fileName).appendingPathExtension("plist")
////            print("Library directory:", userDefaultsPlistURL.path)
////            print("Preferences directory:", userDefaultsPlistURL.path)
////            print("UserDefaults plist file:", userDefaultsPlistURL.path)
//            if FileManager.default.fileExists(atPath: userDefaultsPlistURL.path) {
//                print("file found")
//   
//                drive?.uploadFile("weekly_tally_data", filePath: userDefaultsPlistURL.path, MIMEType: "application/octet-stream") { (fileID, error) in
//                    print("Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
//                }
//                
//            }
//        }
        
    }
    
    
    // MARK: Protocol functions/ Overwritten functions
    @objc func willEnterForeground() {
        //when app comes to foreground, get updated data
        
        updateTitle()
        updateCounters()
        tableView.reloadData()
    }
    
    @objc func addNewTally() {
        self.performSegue(withIdentifier: "AddItem", sender: self)
    }
    
    @objc func goBackToMain(){
        ArchivedState = false
        FutureState = false
        
        // Change button states
        EditBtn.isEnabled = true
        ProfileBtn.isEnabled = true
        ArchivedListBtn.isHidden = false
        FutureListBtn.isHidden = false
        
        // Enable search bar again
        searchController.searchBar.isUserInteractionEnabled = true
        searchController.searchBar.alpha = 1
        
        // Change navigation and tool bars
        updateTitle()
        setupToolBarButtons()
        
        tableView.reloadData()
        scrollToTop()
    }
    
}

protocol customCellDelegate{
    func didTapButton(_ cellCounter: Counter)
}

class customCell: UITableViewCell{
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDailySum: UILabel!
    @IBOutlet weak var cellWeeklySum: UILabel!
    @IBOutlet weak var cellWeekLabel: UILabel!
    @IBOutlet weak var cellDailyAdd: UILabel!
    @IBOutlet weak var cellUnit: UILabel!
    @IBOutlet weak var cellBtn: UIButton!
    @IBOutlet weak var cellProgress: UIProgressView!
    
    var cellDelegate: customCellDelegate?
    var cellCounter: Counter?
    
    @IBOutlet weak var ContainerView: CustomView!
    
    
    @IBAction func buttonPress(_ sender: UIButton) {
        if let cellCounter = cellCounter{
            cellDelegate?.didTapButton(cellCounter)
        }
    }
    
}

extension CounterTableViewController: GIDSignInDelegate {
    // ALL GOOGLE API CALLS
    
    // MARK: - GIDSignInDelegate
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if let error = error {
            googleDriveService.authorizer = nil
            googleUser = nil
            
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }else{
            // Include authorization headers/values with each Drive API request.
            googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            googleUser = user
        }
        
        //        // Perform any operations on signed in user here.
        //        let userId = user.userID                  // For client-side use only!
        //        let idToken = user.authentication.idToken // Safe to send to the server
        //        let fullName = user.profile.name
        //        let givenName = user.profile.givenName
        //        let familyName = user.profile.familyName
        //        let email = user.profile.email
        //        // ...
        //        let photo = user.profile.imageURL(withDimension: <#T##UInt#>)
        
        
        //        let dimension = round(ProfileBtn.width * UIScreen.main.scale)
        //        let pic = user.profile.imageURL(withDimension: dimension)
        
//        // Authenticate with Firebase
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                       accessToken: authentication.accessToken)
//
//        Auth.auth().signIn(with: credential) { (authResult, error) in
//            if let error = error {
//                print("sign in error")
//                return
//            }
//        }
//
//        print("Firebase sign in okay")
        
    }
    
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Did disconnect to user")
    }
    
    public func setupGoogleSignIn() {
        
        /***** Configure Google Sign In *****/
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    

}

//extension UITableViewController: GIDSignInUIDelegate {}





