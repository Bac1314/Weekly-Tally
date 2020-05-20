//
//  InstructViewController.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 2020/5/7.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

class InstructViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startBtn: UIButton!
    
    var instructions: [CustomSlide] = []
    var frame = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructions = createSlides()
        
        navigationController?.isToolbarHidden = true
        navigationController?.navigationBar.isHidden = true

        pageControl.numberOfPages = instructions.count
        setupScreens()
        
        scrollView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        
        if(Int(pageNumber) == instructions.count-1){
            startBtn.isHidden = false
        }
    }
    
    
     // MARK: Private Methods
    private func setupScreens() {
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(instructions.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< instructions.count {
            instructions[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(instructions[i])
        }
        
    }

    
    private func createSlides() -> [CustomSlide] {

        let slide1:CustomSlide = Bundle.main.loadNibNamed("CustomSlideXIB", owner: self, options: nil)?.first as! CustomSlide
        slide1.imageView.image = UIImage(named: "WT_Instructions1")
        slide1.labelTitle.text = "Build a habit"
        slide1.labelDesc.text = "Learn a new skill? Exercise more? Build a habit with just 5 to 7 clicks (+) per week."
        
        let slide2:CustomSlide = Bundle.main.loadNibNamed("CustomSlideXIB", owner: self, options: nil)?.first as! CustomSlide
        slide2.imageView.image = UIImage(named: "WT_Instructions2")
        slide2.labelTitle.text = "Create a weekly goal"
        slide2.labelDesc.text = "Set your weekly goal and let the app calculate how much you need to work on each day."
        
        let slide3:CustomSlide = Bundle.main.loadNibNamed("CustomSlideXIB", owner: self, options: nil)?.first as! CustomSlide
        slide3.imageView.image = UIImage(named: "WT_Instructions3")
        slide3.labelTitle.text = "Track your progress"
        slide3.labelDesc.text = "Track or modify your current week's progress. Or view your total tally and average tally per week."
        
        let slide4:CustomSlide = Bundle.main.loadNibNamed("CustomSlideXIB", owner: self, options: nil)?.first as! CustomSlide
        slide4.imageView.image = UIImage(named: "WT_Instructions4")
        slide4.labelTitle.text = "Sharing is caring"
        slide4.labelDesc.text = "Let your friends and family copy your weekly goal or share your progress to them."
        
        return [slide1, slide2, slide3, slide4]
    }
    
    @IBAction func startNow(_ sender: UIButton) {
          navigationController?.navigationBar.isHidden = false
        
        let isPresentingInAddCounterMode = presentingViewController is UINavigationController
            
             if isPresentingInAddCounterMode {
                 dismiss(animated: true, completion: nil)
             }else if let owningNavigationController = navigationController {
                 owningNavigationController.popViewController(animated: true)
             }else {
                 fatalError("The DetailViewController is not inside a navigation controller.")
             }
    }
    
}
