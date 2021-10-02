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
    func addShadow(xAxis: CGFloat, yAxis: CGFloat, shadowRadius: CGFloat, color: UIColor, shadowOpacity: Float) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = shadowRadius  // 6-8
        self.layer.shadowOpacity = shadowOpacity //0.12
        self.layer.shadowOffset = CGSize(width: xAxis, height: yAxis) // x = 0 , y = 4
    }
}

