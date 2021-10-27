//
//  CBTitleLabel.swift
//  CoffeeBrew
//
//  Created by Ali Dinç on 19/10/2021.
//

import UIKit

class NVLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(fontName: String, fontSize: CGFloat, textColor: UIColor, textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.font                                      = UIFont(name: fontName, size: fontSize)
        self.textColor                                 = textColor
        self.textAlignment                             = textAlignment
        adjustsFontSizeToFitWidth                      = true
        translatesAutoresizingMaskIntoConstraints      = false
    }
}
