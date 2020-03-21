//
//  CustomBarView.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/18/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

@IBDesignable class CustomBarView: UIView {

    @IBInspectable public var progress: CGFloat = 10 {
        didSet {
            viewFront.heightAnchor.constraint(equalToConstant: progress).isActive = true
        }
    }
    
    @IBInspectable public var weekProgress: String = "0" {
        didSet {
            labelScore.text = weekProgress
        }
    }
    
    
    
    var proressAnchor: NSLayoutConstraint!
    
    lazy var labelScore : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.text = "2000"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var viewFront : CustomView = {
        let view = CustomView()
        view.addSubview(labelScore)
        view.backgroundColor = UIColor.systemBlue
        view.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var viewBackground : CustomView = {
        let view = CustomView()
        view.backgroundColor = UIColor.systemFill
        view.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        addSubview(viewFront)
        addSubview(viewBackground)
//        addSubview(labelScore)
        setupLayout()
    }
    
    
    private func setupLayout(){
        // Set parents contraints
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        // Set children constraints
        labelScore.bottomAnchor.constraint(equalTo: viewFront.bottomAnchor, constant: -4).isActive = true
        labelScore.leadingAnchor.constraint(equalTo: viewFront.leadingAnchor, constant: 2).isActive = true
        labelScore.trailingAnchor.constraint(equalTo: viewFront.trailingAnchor, constant: -2).isActive = true
        labelScore.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        labelScore.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        viewBackground.heightAnchor.constraint(equalToConstant: 100).isActive = true
        viewBackground.widthAnchor.constraint(equalToConstant: 30).isActive = true
        viewBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        viewBackground.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        
        viewFront.widthAnchor.constraint(equalToConstant: 30).isActive = true
        viewFront.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        viewFront.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    }
}

