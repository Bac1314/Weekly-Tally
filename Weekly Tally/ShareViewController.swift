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

            // Create new counter (with no data for sharing)
            let newCounter = Counter(title: tempCounter.title, unit: tempCounter.unit, weeklyGoal: tempCounter.weeklyGoal, weekendsIncluded: tempCounter.weekendsIncluded)
            
            newCounter?.dateCreated = tempCounter.dateCreated
            
            
            // Create QR code for sharing
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newCounter) {
                let jsonString = String(data: encoded, encoding: .utf8)!
                guard let qrimage = CustomShare().generateQRCode(from:jsonString) else {return}
                customShareView.QRImage.image = qrimage
            }else{
                customShareView.QRImage.image = nil
            }
           
        
            customShareView.labelTitle.font = UIFont.preferredFont(forTextStyle: .caption2)
            customShareView.labelTitle.text = "WEEKLY TALLY APP"
            customShareView.labelSubtitle.text = tempCounter.title
            customShareView.labelCenterScore.text = String(tempCounter.weeklyGoal)
            customShareView.labelCenterScoreUnit.text = tempCounter.unit ?? "" + "/week"

        
            // SETUP TOTAL PROGRESS
             let allWeeks = CustomTallyCounter().getTotalWeeks(counter: tempCounter, DateCreated: tempCounter.dateCreated, pausedPeriod: 0, activeWeeksSelected: false)


             let labelTitleTOT = "WEEKLY TALLY APP"
             let labelSubtitleTOT = tempCounter.title

             let labelLeftTitleTOT = "Tally (\(Int(allWeeks)) weeks)"
             let labelLeftScoreTOT = String(tempCounter.totalSum)
             let labelLeftScoreUnitTOT = tempCounter.unit ?? ""

             let labelRightTitleTOT = "Average"
             let labelRightScoreTOT = (allWeeks > 1) ? String(Int(Float(tempCounter.totalSum)/allWeeks)) :  String(Int(Float(tempCounter.totalSum)))
             let labelRightScoreUnitTOT = "\(tempCounter.unit ?? "")/week"
            
            customOverViewGraph.labelGraphFoot.isHidden = true


             let aOverviewTOT = overview(title: labelTitleTOT, subtitle: labelSubtitleTOT, leftTitle: labelLeftTitleTOT, leftSub: labelLeftScoreTOT, leftUnit: labelLeftScoreUnitTOT, rightTitle: labelRightTitleTOT, rightSub: labelRightScoreTOT, rightUnit: labelRightScoreUnitTOT)

             customOverViewGraph.overview_data = aOverviewTOT
             customOverViewGraph.history_data = CustomTallyCounter().getListOfWeekTallies(counter: tempCounter, activeWeeksSelected: false)
            
            customOverViewGraph.labelTitle.font = UIFont.preferredFont(forTextStyle: .caption2)

            
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
        let image = UIImage(view: view)

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image is saved to your photo library.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
}
