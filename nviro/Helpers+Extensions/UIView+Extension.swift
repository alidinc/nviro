//
//  UIView+Extension.swift
//  nviro
//
//  Created by Ali Dinç on 21/09/2021.
//

import UIKit

extension UIView {
    func fadeIn(duration: TimeInterval, delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.isHidden = false
        })
    }
    
    func fadeOut(duration: TimeInterval, delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.isHidden = true
        })
    }
    
    func fadeIn2(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: .transitionCurlUp, animations: {
            self.isHidden = false
        })
    }
    
    func fadeOut2(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: .transitionCurlDown, animations: {
            self.isHidden = true
        })
    }
}


extension UIView {
    func addShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.layer.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
