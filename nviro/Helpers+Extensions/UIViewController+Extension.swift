//
//  UIView+Extension.swift
//  nviro
//
//  Created by Ali Dinç on 04/09/2021.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
     func addShadow(to view: UIView) {
         view.layer.masksToBounds = false
         view.layer.shadowColor = UIColor.darkGray.cgColor
         view.layer.shadowOffset = .zero
         view.layer.shadowOpacity = 1
         view.layer.shadowRadius = 10
         view.layer.shadowPath = UIBezierPath(rect: view.layer.bounds).cgPath
         view.layer.shouldRasterize = true
         view.layer.rasterizationScale = UIScreen.main.scale
    }
}
