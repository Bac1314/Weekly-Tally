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
            updateProgress()
        }
    }
    
    var proressAnchor: NSLayoutConstraint!
    
    lazy var viewFront : CustomView = {
        let view = CustomView()
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
        setupLayout()
    }
    
    func updateProgress(){
//        proressAnchor.constant = progress
        viewFront.heightAnchor.constraint(equalToConstant: progress).isActive = true
    }
    
    private func setupLayout(){
        // Set parents contraints
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Set children constraints
        viewBackground.heightAnchor.constraint(equalToConstant: 100).isActive = true
        viewBackground.widthAnchor.constraint(equalToConstant: 30).isActive = true
        viewBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        viewBackground.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
//        proressAnchor = viewFront.heightAnchor.constraint(equalToConstant: progress)
//        proressAnchor.isActive = true
        
        viewFront.widthAnchor.constraint(equalToConstant: 30).isActive = true
        viewFront.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        viewFront.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    }
}

