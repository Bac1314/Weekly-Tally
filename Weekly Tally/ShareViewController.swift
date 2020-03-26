//
//  ShareViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/23/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    @IBOutlet weak var customShareView: CustomShareView!
    @IBOutlet weak var customOverViewGraph: CustomOverviewGraph!

    var counter: Counter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCardvalues()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func shareAction(_ sender: Any) {
        guard let qrimage = CustomShare().generateQRCode(from: "Bac is cool") else { return }

        customShareView.QRImage.image = qrimage
        
        sharePhoto(view: customShareView)
    }
    
    @IBAction func igAction(_ sender: Any) {
        igShare(view: customShareView)
    }
    
    @IBAction func downloadAction(_ sender: Any) {
        downloadPhoto(view: customShareView)
    }
    
    @IBAction func shareActionTotal(_ sender: Any) {
        sharePhoto(view: customOverViewGraph)
    }
    
    @IBAction func igActionTotal(_ sender: Any) {
        igShare(view: customOverViewGraph)
    }
    
    @IBAction func downloadActionTotal(_ sender: Any) {
        downloadPhoto(view: customOverViewGraph)
    }
    
    
    // MARK: Private functions
    
    private func setupCardvalues(){
        
        if let tempCounter = counter{
            
//            // SETUP WEEKLY PROGRESS
//            let fractionDone = Float(tempCounter.weeklySum)/Float(tempCounter.weeklyGoal)
//            let percentage = String(Int(fractionDone * 100)) + "%"
//
//            let labelTitle = "CURRENT WEEK"
//            let labelSubtitle = "\(tempCounter.weeklyGoal) \(tempCounter.unit ?? "unit") per week"
//
//            let labelLeftTitle = "Tally"
//            let labelLeftScore = String(tempCounter.weeklySum)
//            let labelLeftScoreUnit = tempCounter.unit ?? ""
//
//            let labelRightTitle = "Progress"
//            let labelRightScore = percentage
//            let labelRightScoreUnit = "completed"
//
//            let aOverview = overview(title: labelTitle, subtitle: labelSubtitle, leftTitle: labelLeftTitle, leftSub: labelLeftScore, leftUnit: labelLeftScoreUnit, rightTitle: labelRightTitle, rightSub: labelRightScore, rightUnit: labelRightScoreUnit)
            
//            customShareView.overview_data = aOverview
//            customOverview.setupData()
            
            customShareView.labelTitle.text = "Weekly Tally App"
            customShareView.labelSubtitle.text = tempCounter.title
            customShareView.labelCenterScore.text = String(tempCounter.weeklyGoal)
            customShareView.labelCenterScoreUnit.text = tempCounter.unit ?? "" + "/week"
  
        
            // SETUP TOTAL PROGRESS
             let allWeeks = CustomTallyCounter().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: 0, activeWeeksSelected: false)


             let labelTitleTOT = "Weekly Tally App"
             let labelSubtitleTOT = tempCounter.title

             let labelLeftTitleTOT = "Tally (\(Int(allWeeks))weeks)"
             let labelLeftScoreTOT = String(tempCounter.totalSum)
             let labelLeftScoreUnitTOT = tempCounter.unit ?? ""

             let labelRightTitleTOT = "Average"
             let labelRightScoreTOT = (allWeeks > 0) ? String(Int(Float(tempCounter.totalSum)/allWeeks)) :  "-"
             let labelRightScoreUnitTOT = "\(tempCounter.unit ?? "")/week"
            
            customOverViewGraph.labelGraphFoot.isHidden = true


             let aOverviewTOT = overview(title: labelTitleTOT, subtitle: labelSubtitleTOT, leftTitle: labelLeftTitleTOT, leftSub: labelLeftScoreTOT, leftUnit: labelLeftScoreUnitTOT, rightTitle: labelRightTitleTOT, rightSub: labelRightScoreTOT, rightUnit: labelRightScoreUnitTOT)

             customOverViewGraph.overview_data = aOverviewTOT
             customOverViewGraph.history_data = CustomTallyCounter().getListOfWeekTallies(counter: tempCounter, activeWeeksSelected: false)
        
//             customOverviewTotal.setupData()
            
        }
    }
    
    
    
    private func sharePhoto(view: UIView){
        
        let image = UIImage(view: view)

        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
            if completed {
                print("completed")
            } else {
                print("cancled")
            }
        }
        present(activityController, animated: true)
    }
    
    
    private func igShare(view: UIView){
        // Share on instagram stories
        if let storiesUrl = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                //                guard let image = sharingImageView.image else { return }
                let image = UIImage(view: view)
                guard let imageData = image.pngData() else { return }
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.stickerImage": imageData,
                    "com.instagram.sharedSticker.backgroundTopColor":  "#34b1eb",
                    "com.instagram.sharedSticker.backgroundBottomColor": "#bff2eb"
                ]
                
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
            } else {
                print("User doesn't have instagram on their device.")
            }
        }
    }
    
    private func downloadPhoto(view: UIView){
        
    }
    
    
}
