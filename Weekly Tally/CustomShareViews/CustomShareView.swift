//
//  CustomShareView.swift
//  Weekly Tally
//
//  Created by Bac Cheng Huang on 3/22/20.
//  Copyright © 2020 THEBAC. All rights reserved.
//

import UIKit

@IBDesignable class CustomShareView: CustomView {
    
    @IBInspectable public var backColor:UIColor? = UIColor.init(named: "TallyCard") {
        didSet {
            backgroundColor = backColor
        }
    }
    
    @IBInspectable public var textColor:UIColor? = UIColor.label {
        didSet {
            labelSubtitle.textColor = textColor
            labelCenterTitle.textColor = textColor
            labelCenterScoreUnit.textColor = textColor
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
    
    
    lazy var labelCenterTitle : UILabel = {
        let label = UILabel()
        label.text = "WEEKLY GOAL"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.alpha = 0.7
        label.textColor = UIColor.lightGray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelCenterScore : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.text = "1000"
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelCenterScoreUnit : UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "unit/week"
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var QRImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "qrcode")
        image.contentMode = .scaleAspectFit
        image.autoresizesSubviews = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
   
        backgroundColor = backColor
        addSubview(labelTitle)
        addSubview(labelSubtitle)
        addSubview(viewDivider)
        addSubview(labelCenterTitle)
        addSubview(labelCenterScore)
        addSubview(labelCenterScoreUnit)
        addSubview(QRImage)
        setupLayout()
        
    }
    
    func setupData(){

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
        
        labelCenterTitle.topAnchor.constraint(equalTo: viewDivider.bottomAnchor, constant: 16).isActive = true
        labelCenterTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelCenterTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        labelCenterScore.heightAnchor.constraint(equalToConstant: 34).isActive = true
        labelCenterScore.topAnchor.constraint(equalTo: labelCenterTitle.bottomAnchor, constant: 4).isActive = true
        labelCenterScore.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelCenterScore.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        labelCenterScoreUnit.topAnchor.constraint(equalTo: labelCenterScore.bottomAnchor, constant: 0).isActive = true
        labelCenterScoreUnit.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        labelCenterScoreUnit.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true

        

        QRImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        QRImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        QRImage.heightAnchor.constraint(equalTo: QRImage.widthAnchor, multiplier: 1.0/1.0).isActive = true
        QRImage.topAnchor.constraint(equalTo: labelCenterScoreUnit.bottomAnchor, constant: 16).isActive = true
        QRImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true
        
    }
}
