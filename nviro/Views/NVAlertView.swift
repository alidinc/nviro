//
//  CBAlertView.swift
//  CoffeeBrew
//
//  Created by Ali Dinç on 21/10/2021.
//

import UIKit

class NVAlertVC: UIViewController {
    
    // MARK: - Properties
    let containerView = UIView()
    let titleLabel = NVLabel(fontName: "Galvji", fontSize: 20, textColor: .black, textAlignment: .center)
    let messageLabel = NVLabel(fontName: "Galvji", fontSize: 16, textColor: .black, textAlignment: .center)
    let actionButton = NVButton(backgroundColor: UIColor(named: "Pine")!, title: "OK")
    
    // properties to initialize with this custom alertVC
    var alertTitle: String?
    var message: String?
    var buttonTitle: String?
    
    // padding for layout constraint
    let padding: CGFloat = 12
    
    // custom action
    @objc private var handler: (() -> Void)!
    
    // custom initialization
    init(title: String, message: String, buttonTitle: String, with handler: @escaping () -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.handler = handler
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        configureContainerView()
        configureTitleLabel()
        configureActionButton()
        configureMessageLabel()
    }
    // MARK: - Helpers
    func configureContainerView() {
        view.addSubview(containerView)
        containerView.layer.cornerRadius        = 16
        containerView.layer.borderWidth         = 2
        containerView.layer.borderColor         = UIColor.white.cgColor
        containerView.backgroundColor           = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    func configureTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.text = alertTitle ?? "Something went wrong"
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    func configureActionButton() {
        containerView.addSubview(actionButton)
        actionButton.setTitle(buttonTitle ?? "OK", for: .normal)
        actionButton.addTarget(self, action: #selector(invoke), for: .touchUpInside)
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    @objc func invoke () {
        handler()
    }
    
    func configureMessageLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.numberOfLines = 2
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12)
        ])
    }
}
