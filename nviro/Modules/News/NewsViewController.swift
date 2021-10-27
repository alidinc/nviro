//
//  SettingsViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollTopButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: - Properties
    var articles = [Article]()
    var refresh = UIRefreshControl()
    var cellImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    func setupView() {
        indicator.isHidden = true
        scrollTopButton.isHidden = true
        backgroundView.layer.cornerRadius = 30
        refreshSetup()
        tableViewSetup()
        getNewsFromNetwork()
    }
    fileprivate func tableViewSetup() {
        tableView.layer.cornerRadius = 20
        tableView.register(UINib(nibName: Constants.Identifiers.newsTableViewCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.newsTableViewCellID)
    }
    fileprivate func refreshSetup() {
        let string = "Pull down to read the latest news"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "Galvji", size: 12)!
        ]
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        refresh.attributedTitle = attributedString
        refresh.addTarget(self, action: #selector(getNewsFromNetwork), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    @objc fileprivate func getNewsFromNetwork() {
        self.showLoadingView()
        indicator.isHidden = false
        indicator.startAnimating()
        NetworkService.getNews(with: "climate") { result in
            self.dismissLoadingView()
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                switch result {
                case .success(let articles):
                    self.articles = articles
                    self.refresh.endRefreshing()
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    self.presentGGAlertOnMainThread(title: "No network", message: "Please check your network", buttonTitle: "OK") {
                        self.dismiss(animated: true, completion: nil)
                        self.showEmptyStateView(with: "There's no network. Please check your settings.", in: self.backgroundView)
                    }
                }
            }
        }
    }
    func setupNewsImageView() {
        
    }
    @IBAction func arrowTapped(_ sender: UIButton) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension NewsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        offsetY > 400 ? scrollTopButton.fadeIn(duration: 1.0) : scrollTopButton.fadeOut(duration: 1.0)
    }
}
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.newsTableViewCellID, for: indexPath) as? NewsCell else { return UITableViewCell() }
        cell.article = articles[indexPath.row]
        cell.newsImageView.image = self.cellImage
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        let articleURL = article.url
        self.showWebsite(with: articleURL)
    }
}

extension NewsViewController {
    func showWebsite(with url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
}
