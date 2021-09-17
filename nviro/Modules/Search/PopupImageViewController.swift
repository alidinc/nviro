//
//  PopupImageViewController.swift
//  nviro
//
//  Created by Ali Dinç on 08/09/2021.
//

import UIKit

class PopupImageViewController: UIViewController {
    
    // MARK: - Properties
    var popupImage: UnsplashImage? {
        didSet {
            getImageForCity()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var popupImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        popupImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Helpers
    func getImageForCity() {
        guard let url = popupImage?.urls.regularURL else { return }
        NetworkService.fetchImage(with: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.popupImageView.image = image
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
