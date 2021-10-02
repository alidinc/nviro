//
//  CityImageCollectionViewCell.swift
//  nviro
//
//  Created by Ali Dinç on 07/09/2021.
//

import UIKit

class CityImageCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    var cityImage: UnsplashImage? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        indicator.isHidden = true
        cityImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Helpers
    func updateView() {
        guard let cityImage = cityImage else { return }
        indicator.isHidden = false
        indicator.startAnimating()
        NetworkService.fetchImage(with: cityImage.urls.regularURL) { result in
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                switch result {
                case .success(let image):
                    self.cityImageView.image = image
                case .failure(let error):
                    self.cityImageView.image = UIImage(named: "NoImageForNews")
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
