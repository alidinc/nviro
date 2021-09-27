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



