//
//  UIView+Extension.swift
//  nviro
//
//  Created by Ali Dinç on 04/09/2021.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
    func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentGGAlertOnMainThread(title: String, message: String, buttonTitle: String, action: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alertVC = NVAlertVC(title: title, message: message, buttonTitle: buttonTitle, with: action)
            alertVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            alertVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(alertVC, animated: true)
        }
    }
    
    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = NVEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.systemBackground
        containerView.alpha           = 0
        UIView.animate(withDuration: 0.25) { containerView.alpha = 0.8 }
        
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        containerView.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        indicator.startAnimating()
    }
    func dismissLoadingView() {
        DispatchQueue.main.async {
            containerView?.removeFromSuperview()
            containerView = nil
        }
    }
}
