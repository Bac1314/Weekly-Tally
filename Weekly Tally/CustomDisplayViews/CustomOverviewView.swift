//
//  CustomOverviewView.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/14/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

@IBDesignable class CustomOverviewView: CustomView {
    
    var overview_data: overview? {
        didSet{
            setupData()
        }
    }
    
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
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelLeftScoreUnit : UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "UNIT"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.lightGray
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
    
//    lazy var viewDivider2 : UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.separator
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var progressView : CustomProgressView = {
//        let progressview = CustomProgressView()
//        progressview.cornerRadius = 4
//        progressview.translatesAutoresizingMaskIntoConstraints = false
//        return progressview
//    }()
//
//    lazy var labelPercentage : UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
//        label.text = "89%"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var labelPercentDescription : UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 2
//        label.text = "You have completed 80% over your weekly goal"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = UIColor.lightGray
//        return label
//    }()
    
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
//        borderWidth = 0.3
//        borderColor = UIColor.white
        cornerRadius = 20
        backgroundColor = UIColor.init(named: "TallyCard")
        addSubview(labelTitle)
        addSubview(labelSubtitle)
        addSubview(viewDivider)
        addSubview(stackParent)
        setupLayout()

    }
    
    func setupData(){
        
        if let overview_data = overview_data {
            
//            let fractionDone = overview_data.aProgress
//            progressView.setProgress(fractionDone >= 1 ? 1 : Float(fractionDone), animated: true)
            
            labelTitle.text = overview_data.title
            labelSubtitle.text = overview_data.subtitle

            labelLeftTitle.text = overview_data.leftTitle
            labelLeftScore.text = overview_data.leftSub
            labelLeftScoreUnit.text = overview_data.leftUnit
            
            labelRightTitle.text = overview_data.rightTitle
            labelRightScore.text = overview_data.rightSub
            labelRightScoreUnit.text = overview_data.rightUnit
        
//            labelPercentDescription.text = overview_data.aProgressTitle
        }

    }
   
    private func setupLayout(){
        
//        progressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
////        progressView.heightAnchor.constraint(equalToConstant: 6).isActive = true
//        progressView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.centerXAnchor, multiplier: 0).isActive = true
//        progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
//        progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
//
        
        labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        labelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        labelSubtitle.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 4).isActive = true
        labelSubtitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        viewDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        viewDivider.topAnchor.constraint(equalTo: labelSubtitle.bottomAnchor, constant: 8).isActive = true
        viewDivider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        viewDivider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:
            -16).isActive = true
        
        
        
        stackParent.heightAnchor.constraint(equalToConstant: 90).isActive = true
        stackParent.topAnchor.constraint(equalTo: viewDivider.bottomAnchor, constant: 8).isActive = true
        stackParent.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        stackParent.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        stackParent.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24).isActive = true
        
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
        
//        viewDivider2.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
//        viewDivider2.topAnchor.constraint(equalTo: stackParent.bottomAnchor, constant: 8).isActive = true
//        viewDivider2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
//        viewDivider2.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
//

        
//        labelPercentage.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 24).isActive = true
//        labelPercentage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
//        labelPercentage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
//
//        labelPercentDescription.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8).isActive = true
//        labelPercentDescription.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16).isActive = true
//        labelPercentDescription.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
//        labelPercentDescription.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24).isActive = true
        
    }
}

