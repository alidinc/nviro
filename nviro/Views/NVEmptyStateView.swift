//
//  GGEmptyStateView.swift
//  goodgames
//
//  Created by Ali Dinç on 18/10/2021.
//

import Foundation
import UIKit

class NVEmptyStateView: UIView {
    
    let messageLabel = NVLabel(fontName: "Galvji", fontSize: 16, textColor: .white, textAlignment: .center)
    let logoImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        configure()
        
    }
    private func configure() {
        addSubview(messageLabel)
        addSubview(logoImageView)
        
        messageLabel.numberOfLines = 3
        messageLabel.backgroundColor = UIColor(named: "Pine")!
        messageLabel.layer.cornerRadius = 20
        messageLabel.layer.masksToBounds = true
        logoImageView.image = UIImage(named: "leaves")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            messageLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            logoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            logoImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            logoImageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -80)
        ])
    }
}
