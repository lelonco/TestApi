//
//  ShadowTextView.swift
//  TestApi
//
//  Created by Yaroslav on 19.12.2020.
//

import UIKit

class ShadowTextView: UITextView {
    
    override var bounds: CGRect {
        didSet {
            updateShadow()
        }
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        
        self.autoSetDimension(.height, toSize: 40,relation: .greaterThanOrEqual)
        self.font = .systemFont(ofSize: 15, weight: .medium)
        self.isScrollEnabled = false
        self.layer.cornerRadius = 15
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 6)
        self.layer.shadowOpacity = 0.07
        self.layer.shadowRadius = 4
        self.layer.shadowPath =  UIBezierPath(roundedRect: self.bounds, cornerRadius: 15).cgPath
        self.layer.masksToBounds = false
    }
    
}
