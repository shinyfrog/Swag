//
//  PercentLayoutConstraint.swift
//  Swag
//
//  Created by Matteo Rattotti on 09/05/2018.
//  Copyright © 2018 Matteo Rattotti. All rights reserved.
//

import UIKit

@IBDesignable
class PercentLayoutConstraint: NSLayoutConstraint {
    @IBInspectable var marginPercent: CGFloat = 0
    
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self,
                                                       selector: #selector(layoutDidChange),
                                                       name: NSNotification.Name.UIDeviceOrientationDidChange,
                                                       object: nil)
    }
    
    /**
     Re-calculate constant based on orientation and percentage.
     */
    @objc func layoutDidChange() {
        switch firstAttribute {
        case .top, .topMargin, .bottom, .bottomMargin:
            constant = screenSize.height * marginPercent
        case .leading, .leadingMargin, .trailing, .trailingMargin:
            constant = screenSize.width * marginPercent
        default: break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
