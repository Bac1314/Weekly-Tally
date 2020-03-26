//
//  CustomOverviewGraph.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/18/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

@IBDesignable class CustomOverviewGraph: CustomView {
    
    var overview_data: overview? {
        didSet{
            updateData()
        }
    }
    var history_data: [Int]? = [] {
        didSet{
            setupData()
        }
    }
    
    @IBInspectable public var backColor:UIColor? = UIColor.init(named: "TallyCard") {
        didSet {
            backgroundColor = backColor
        }
    }
    @IBInspectable public var textColor:UIColor? = UIColor.label {
        didSet {
            labelSubtitle.textColor = textColor
            labelLeftScore.textColor = textColor
            labelRightScore.textColor = textColor
            
         }
    }
    @IBInspectable public var footHidden:Bool = false

    
    lazy var labelTitle : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "Your weekly goal for this activity"
        label.textColor = UIColor.systemBlue
        //      label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelSubtitle : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.text = "400 pushups per week"
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var viewDivider : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackBars : UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    lazy var viewBarBackground : UIView = {
        let view = UIView()
        view.addSubview(stackBars)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var labelLeftTitle : UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "This week"
        label.textColor = UIColor.lightGray
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelLeftScore : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.text = "1000"
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelLeftScoreUnit : UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "UNIT"
        label.textColor = UIColor.lightGray
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelRightTitle : UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Today"
        label.textColor = UIColor.lightGray
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelRightScore : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.text = "100"
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelRightScoreUnit : UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "UNIT"
        label.textColor = UIColor.lightGray
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    lazy var viewLeft : UIView = {
        let viewLeft = UIView()
        viewLeft.addSubview(labelLeftTitle)
        viewLeft.addSubview(labelLeftScore)
        viewLeft.addSubview(labelLeftScoreUnit)

        viewLeft.translatesAutoresizingMaskIntoConstraints = false
        return viewLeft
    }()
    
    lazy var viewRight : UIView = {
        let viewRight = UIView()
        viewRight.addSubview(labelRightTitle)
        viewRight.addSubview(labelRightScore)
        viewRight.addSubview(labelRightScoreUnit)

        viewRight.translatesAutoresizingMaskIntoConstraints = false
        return viewRight
    }()
    
    lazy var stackParent : UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.addArrangedSubview(viewLeft)
        stackview.addArrangedSubview(viewRight)

        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()


    lazy var labelGraphFoot : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "Note: Shake to see active weeks only"
        label.textColor = UIColor.lightGray
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = footHidden
        return label
    }()
    
    //MARK: Initialization
    //programatically initializing the view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    //loading the view from the storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    
    //MARK: Private Methods
    private func setupViews() {

        cornerRadius = 20
        backgroundColor = backColor
//            UIColor.init(named: "TallyCard")
        
        addSubview(labelTitle)
        addSubview(labelSubtitle)
        addSubview(viewDivider)
        addSubview(viewBarBackground)
//        addSubview(stackBars)
//        addSubview(viewDivider2)
        addSubview(stackParent)
        addSubview(labelGraphFoot)
        setupLayout()
        
    }
    
    func setupData(){
        if let overview_data = overview_data {

            labelTitle.text = overview_data.title
            labelSubtitle.text = overview_data.subtitle

            labelLeftTitle.text = overview_data.leftTitle
            labelLeftScore.text = overview_data.leftSub
            labelLeftScoreUnit.text = overview_data.leftUnit
            
            labelRightTitle.text = overview_data.rightTitle
            labelRightScore.text = overview_data.rightSub
            labelRightScoreUnit.text = overview_data.rightUnit
        }
        
        // SETUP BARS
        
        var max_score: Int = 1
        // Remove bars if exist
        stackBars.subviews.forEach({ $0.removeFromSuperview() })
    
        if let history_data = history_data{
        
            if history_data.count >= 1 {
                stackBars.heightAnchor.constraint(equalToConstant: 100).isActive = true
     
                let count = history_data.count < 5 ? history_data.count : 5
                
                // Get the max score
                 for n in history_data.count-count...history_data.count-1 {
                     if history_data[n] > max_score {
                         max_score = history_data[n]
                     }
                 }
                 
                // Setup empty bars
                if count < 5 {
                    for _ in 1...5-count {
                        let progressView : CustomBarView = {
                            
                            let progressview = CustomBarView()
                            progressview.progress = CGFloat(0)
//                            progressview.viewBackground.backgroundColor = UIColor.init(named: "TallyCard")
                            progressview.viewBackground.alpha = 0.35
//                            progressview.viewBackground.borderWidth = 0.4
//                            progressview.viewBackground.borderColor = UIColor.systemGray
                            progressview.labelScore.text = "-"

                            progressview.translatesAutoresizingMaskIntoConstraints = false
                            return progressview
                           }()

                        stackBars.addArrangedSubview(progressView)
                    }
                }

                 // Setup the bars
                 for n in history_data.count-count...history_data.count-1  {
                        let progressView : CustomBarView = {
                            let progressview = CustomBarView()
                            progressview.progress = CGFloat((Float(history_data[n])/Float(max_score))*100)
                            progressview.labelScore.text = String(history_data[n])
                          
                            progressview.translatesAutoresizingMaskIntoConstraints = false
                            return progressview
                        }()

                     stackBars.addArrangedSubview(progressView)
                 }
                
            }else{
                stackBars.heightAnchor.constraint(equalToConstant: 0).isActive = true
            }
            
//            //Set up the max line
//            let weeklyGoalViewLine :  CustomView = {
//                let view = CustomView()
//                view.cornerRadius = 4
//                view.backgroundColor = UIColor.green
//                view.borderWidth = 0.4
//                view.borderColor = UIColor.white
//                view.translatesAutoresizingMaskIntoConstraints = false
//                return view
//            }()
//
//            viewBarBackground.addSubview(weeklyGoalViewLine)
//
//            weeklyGoalViewLine.heightAnchor.constraint(equalToConstant: 4.0).isActive = true
//            weeklyGoalViewLine.leadingAnchor.constraint(equalTo: viewBarBackground.leadingAnchor, constant: 0).isActive = true
//            weeklyGoalViewLine.trailingAnchor.constraint(equalTo: viewBarBackground.trailingAnchor, constant: 0).isActive = true
//            weeklyGoalViewLine.bottomAnchor.constraint(equalTo: viewBarBackground.bottomAnchor, constant: -50).isActive = true
            

        }

    }
    
    
    func updateData(){
    
        if let overview_data = overview_data {
            labelTitle.text = overview_data.title
            labelSubtitle.text = overview_data.subtitle
            
            labelLeftScore.text = overview_data.leftSub
            labelRightScore.text = overview_data.rightSub
        }
    }
    
    
    private func setupLayout(){
        
        
        labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16).isActive = true
        
        labelSubtitle.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 4).isActive = true
        labelSubtitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        viewDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        viewDivider.topAnchor.constraint(equalTo: labelSubtitle.bottomAnchor, constant: 8).isActive = true
        viewDivider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        viewDivider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        viewBarBackground.topAnchor.constraint(equalTo: viewDivider.bottomAnchor, constant: 8).isActive = true
        viewBarBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24).isActive = true
        viewBarBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24).isActive = true
        
//        stackBars.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stackBars.topAnchor.constraint(equalTo: viewBarBackground.topAnchor, constant: 0).isActive = true
        stackBars.leadingAnchor.constraint(equalTo: viewBarBackground.leadingAnchor, constant: 0).isActive = true
        stackBars.trailingAnchor.constraint(equalTo: viewBarBackground.trailingAnchor, constant: 0).isActive = true
        stackBars.bottomAnchor.constraint(equalTo: viewBarBackground.bottomAnchor, constant: 0).isActive = true
        

//        viewDivider2.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
//        viewDivider2.topAnchor.constraint(equalTo: stackBars.bottomAnchor, constant: 8).isActive = true
//        viewDivider2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
//        viewDivider2.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
    
        stackParent.heightAnchor.constraint(equalToConstant: 90).isActive = true
        stackParent.topAnchor.constraint(equalTo: viewBarBackground.bottomAnchor, constant: 8).isActive = true
        stackParent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        stackParent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        labelLeftTitle.topAnchor.constraint(equalTo: viewLeft.topAnchor, constant: 8).isActive = true
        labelLeftTitle.leadingAnchor.constraint(equalTo: viewLeft.leadingAnchor, constant: 8).isActive = true
        labelLeftTitle.trailingAnchor.constraint(equalTo: viewLeft.trailingAnchor, constant: -8).isActive = true
        
        labelLeftScore.topAnchor.constraint(equalTo: labelLeftTitle.bottomAnchor, constant: 8).isActive = true
        labelLeftScore.leadingAnchor.constraint(equalTo: viewLeft.leadingAnchor, constant: 8).isActive = true
        labelLeftScore.trailingAnchor.constraint(equalTo: viewLeft.trailingAnchor, constant: -8).isActive = true
        
        labelLeftScoreUnit.topAnchor.constraint(equalTo: labelLeftScore.bottomAnchor, constant: 0).isActive = true
        labelLeftScoreUnit.leadingAnchor.constraint(equalTo: viewLeft.leadingAnchor, constant: 8).isActive = true
        labelLeftScoreUnit.trailingAnchor.constraint(equalTo: viewLeft.trailingAnchor, constant: -8).isActive = true
        
        
        labelRightTitle.topAnchor.constraint(equalTo: viewRight.topAnchor, constant: 8).isActive = true
        labelRightTitle.leadingAnchor.constraint(equalTo: viewRight.leadingAnchor, constant: 8).isActive = true
        labelRightTitle.trailingAnchor.constraint(equalTo: viewRight.trailingAnchor, constant: -8).isActive = true
        
        labelRightScore.topAnchor.constraint(equalTo: labelRightTitle.bottomAnchor, constant: 8).isActive = true
        labelRightScore.leadingAnchor.constraint(equalTo: viewRight.leadingAnchor, constant: 8).isActive = true
        labelRightScore.trailingAnchor.constraint(equalTo: viewRight.trailingAnchor, constant: -8).isActive = true
        
        labelRightScoreUnit.topAnchor.constraint(equalTo: labelRightScore.bottomAnchor, constant: 0).isActive = true
        labelRightScoreUnit.leadingAnchor.constraint(equalTo: viewRight.leadingAnchor, constant: 8).isActive = true
        labelRightScoreUnit.trailingAnchor.constraint(equalTo: viewRight.trailingAnchor, constant: -8).isActive = true
        
        
        labelGraphFoot.topAnchor.constraint(equalTo: stackParent.bottomAnchor, constant: 16).isActive = true
        labelGraphFoot.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24).isActive = true
        labelGraphFoot.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24).isActive = true
        labelGraphFoot.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true
        
    }
}
