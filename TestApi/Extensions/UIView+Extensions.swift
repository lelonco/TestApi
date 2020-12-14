//
//  UIView+Extensions.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import UIKit


extension UIView {
    
    static func hSpacer(width:Int) -> UIView {
        let view = UIView()
        view.autoSetDimensions(to: CGSize(width: width, height: 1))
        return view
    }
}

extension UIView {
    @discardableResult
    func autoHCenterInSuperview() -> NSLayoutConstraint {
        return autoAlignAxis(.vertical, toSameAxisOf: self.superview!)
    }
    
    @discardableResult
    func autoVCenterInSuperview() -> NSLayoutConstraint {
        return autoAlignAxis(.horizontal, toSameAxisOf: self.superview!)
    }
}
