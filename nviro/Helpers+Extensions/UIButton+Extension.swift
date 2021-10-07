//
//  UIButton+Extension.swift
//  nviro
//
//  Created by Ali Dinç on 06/10/2021.
//

import Foundation
import UIKit


extension UIButton {
    func styleFilledButton(fillColor: UIColor, radius: Double, tintColor: UIColor) {
        self.backgroundColor = fillColor
        self.layer.cornerRadius = radius
        self.tintColor = tintColor
    }
}
