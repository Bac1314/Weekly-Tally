//
//  SetttingsTableViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 2020/5/17.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit
import MessageUI

class SetttingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    var reset: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row, and instead, show the state with a checkmark.
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0 && indexPath.row == 0{
            // Google Drive Setup
        }else if indexPath.section == 0 && indexPath.row == 1 {
            // Premium
        }else if indexPath.section == 0 && indexPath.row == 2 {
            // Reset
            let customaction = UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                // Reset User Defaults
                UserDefaults.standard.reset()
                self.reset = true
                self.performSegue(withIdentifier: "unwindSettings", sender: self)
            })

            popUpAlert(title: "Reset", message: "Are you sure you want to delete all your data?", cancelTitle: "Cancel", customAction: customaction)
            
        }else if indexPath.section == 1 && indexPath.row == 0 {
            // Guidelines
        }else if indexPath.section == 1 && indexPath.row == 1 {
            // Feedback
            alertUISendMessageBox(title: "Feedback")
        }else if indexPath.section == 1 && indexPath.row == 2 {
            // About
        }
    }
    
    
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    

}

extension SetttingsTableViewController: MFMailComposeViewControllerDelegate {
    func sendEmail(body: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Weekly Tally Feedback")
            mail.setToRecipients(["bacchenghuang@gmail.com"])
            mail.setMessageBody(body, isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
            popUpAlert(title: "Failed!", message: "Your phone is not setup to send email", cancelTitle: "Got it!", customAction: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    func alertUISendMessageBox(title: String){
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 100)
        
        let messageBox = CustomTextField(frame: CGRect(x: 0, y: 0, width: 250, height: 80))
        messageBox.delegate = self
        messageBox.borderStyle = .roundedRect
        messageBox.placeholder = "Send us your feedbacks, suggestions, ideas, etc."
        vc.view.addSubview(messageBox)
        
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        
        alertController.setValue(vc, forKey: "contentViewController")
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler: { (UIAlertAction) in
            
            self.sendEmail(body: messageBox.text ?? "Empty body")
            
        }))
        
        present(alertController, animated: true)
    }
    
    func popUpAlert(title: String, message: String, cancelTitle: String, customAction: UIAlertAction?){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        
        if customAction != nil{
            alert.addAction(customAction!)
        }
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UserDefaults {

    enum Keys: String, CaseIterable {

//        case firstTime
        case LastUpdate
        case savedCounters
        case LastRun
    }

    public func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
