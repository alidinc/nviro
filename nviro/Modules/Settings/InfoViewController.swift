//
//  SettingsViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import Firebase
import UIKit
import SafariServices
import WebKit

class InfoViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var webViewForNasa: WKWebView!
    @IBOutlet weak var backgroundViewForWebview: UIView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var quoteBackgroundView: UIView!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var moreInfoButton2: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWebView()
    }
    
    // MARK: - Helpers
    func setupView() {
        setupNavigationBar()
        indicator.isHidden = true
        moreInfoButton.layer.cornerRadius = 12
        moreInfoButton.layer.masksToBounds = true
        moreInfoButton2.layer.cornerRadius = 12
        moreInfoButton2.layer.masksToBounds = true
        quoteBackgroundView.layer.cornerRadius = 20
        webViewForNasa.layer.cornerRadius = 20
        webViewForNasa.layer.masksToBounds = true
        quoteLabel.text = """
            Scientific evidence for warming of the climate system is unequivocal.
                 - Intergovernmental Panel on Climate Change
            """
        
        self.addShadow(to: moreInfoButton)
        self.addShadow(to: moreInfoButton2)
        self.addShadow(to: quoteBackgroundView)
        self.addShadow(to: backgroundViewForWebview)
    }
    
    fileprivate func setupWebView() {
        indicator.isHidden = false
        indicator.startAnimating()
        guard let url = URL(string: "https://www.wwf.org.uk/thingsyoucando") else { return }
        DispatchQueue.main.async {
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            self.webViewForNasa.load(URLRequest(url: url))
        }
    }
    
    fileprivate func setupNavigationBar() {
        let leavesView = UIImageView(image: UIImage(named: "leaves"))
        leavesView.contentMode = .scaleAspectFit
        navigationItem.titleView = leavesView
    }
    
    // MARK: - Actions
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure to log out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "OK", style: .default) { action in
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let signInVC = storyboard.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController else { return }
                signInVC.modalPresentationStyle = .overFullScreen
                self.present(signInVC, animated: true, completion: nil)
            } catch {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showMoreInformationFromNasa(_ sender: UIButton) {
        self.showWebsite(with: "https://climate.nasa.gov/evidence/")
    }
    @IBAction func showMoreInformationFromIPCC(_ sender: UIButton) {
        self.showWebsite(with: "https://www.ipcc.ch/")
    }
}

extension InfoViewController {
    func showWebsite(with url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
}
