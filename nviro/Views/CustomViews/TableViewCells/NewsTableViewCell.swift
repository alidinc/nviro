//
//  NewsTableViewCell.swift
//  nviro
//
//  Created by Ali Dinç on 22/09/2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var newsSourceLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
    // MARK: - Properties
    var article: Article? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // MARK: - Helpers
    func setupView() {
        newsImageView.layer.masksToBounds = true
        newsImageView.layer.cornerRadius = 20
        newsImageView.contentMode = .scaleAspectFill
    }
    func updateViews() {
        guard let article = article else { return }
        newsDescriptionLabel.text = article.articleDescription
        newsSourceLabel.text = article.source.name
        setupNewsImageView()
    }
    
    func setupNewsImageView() {
        guard let articleImageURLString = article?.urlToImage else { return }
        guard let imageURL = URL(string: articleImageURLString) else { return }
        NetworkService.fetchImage(with: imageURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.newsImageView.image = image
                case .failure(let error):
                    self.newsImageView.image = UIImage(named: "NoImageForNews")
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
