//
//  SearchDetailViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import FirebaseFirestore
import Firebase
import UIKit
import CoreLocation

class SearchDetailViewController: UIViewController {
    
    // MARK: - Properties
    let db = Firestore.firestore()
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            getAirQualityForCity()
        }
    }
    
    var cityImages = [UnsplashImage]()
    var searchTermForFetchingImages: String?
    var postalCodeLocation: String?
    let mainStoryboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
    var isFavorite : Bool?
    var documentID: String?
    var likeButton : UIBarButtonItem?
    
    // MARK: - Outlets
    @IBOutlet weak var cityImagesBackgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var airQDetailBackgroundView: UIView!
    @IBOutlet weak var colorIndexImageView: UIImageView!
    @IBOutlet weak var statusVeryPoorView: UIView!
    @IBOutlet weak var statusPoorView: UIView!
    @IBOutlet weak var statusModerateView: UIView!
    @IBOutlet weak var statusFairView: UIView!
    @IBOutlet weak var statusGoodView: UIView!
    @IBOutlet weak var statusVeryPoorButton: UIButton!
    @IBOutlet weak var statusPoorButton: UIButton!
    @IBOutlet weak var statusModerateButton: UIButton!
    @IBOutlet weak var statusFairButton: UIButton!
    @IBOutlet weak var statusGoodButton: UIButton!
    @IBOutlet weak var measurementDate: UILabel!
    @IBOutlet weak var navigateToCarbonVCButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var scrollButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getImagesForCity()
        getAirQualityForCity()
        
        
    }
    
    
    
    // MARK: - Helpers
    fileprivate func hideAirQStatusButtons() {
        statusVeryPoorButton.isHidden = true
        statusPoorButton.isHidden = true
        statusModerateButton.isHidden = true
        statusFairButton.isHidden = true
        statusGoodButton.isHidden = true
    }
    fileprivate func addCornerRadius() {
        cityImagesBackgroundView.layer.cornerRadius = 20
        airQDetailBackgroundView.layer.cornerRadius = 20
        collectionView.layer.cornerRadius = 20
    }
    fileprivate func registerCollectionViewCell() {
        collectionView.register(UINib(nibName: Constants.Identifiers.searchDetailCollectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.searchDetailCollectionViewItemID)
    }
    fileprivate func setupLikeButton() {
        likeButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(tapForLikeButton))
        likeButton?.tintColor = UIColor(named: "Green")
        likeButton?.image =  isFavorite ?? false ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        navigationItem.rightBarButtonItem = likeButton
    }
    func setupView() {
        indicator.isHidden = true
        measurementDate.text = Date().dateToString()
        hideAirQStatusButtons()
        addCornerRadius()
        setupLikeButton()
        registerCollectionViewCell()
    }
    
    @objc func tapForLikeButton() {
        guard let title = title else { return }
        guard let imageURL = self.cityImages.first?.urls.regularURL.absoluteString else { return }
        guard let isFavorite = isFavorite else { return }
        
        if isFavorite {
            let user = UserDefaults.standard.string(forKey: "user")
            db.collection("favorites").document(user!).collection("places").document(self.documentID ?? "").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.isFavorite = false
                    UIView.animate(withDuration: 1.0,
                                   delay: 0.5,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0.2,
                                   options: .transitionCrossDissolve,
                                   animations: {
                        
                        self.likeButton?.image = UIImage(systemName: "heart") },
                                   completion: nil)
                }
            }
        } else {
            saveData(locationName: title, imageURL: imageURL)
        }
    }
    
    fileprivate func switchAirQStatus(airQList: [AirQList]) {
        guard let airQStatus = (airQList.compactMap({ $0.main.aqi })).first else { return }
        switch airQStatus {
        case 1:
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = false
        case 2:
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = false
            statusGoodButton.isHidden = true
        case 3:
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = false
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = true
        case 4:
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = false
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = true
        case 5:
            statusVeryPoorButton.isHidden = false
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = true
        default:
            break
        }
    }
    func getAirQualityForCity() {
        guard let coordinate = coordinate else { return }
        NetworkService.getAirQuality(with: coordinate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let airQList):
                    self.switchAirQStatus(airQList: airQList)
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    func getImagesForCity() {
        guard let searchTerm = searchTermForFetchingImages else { return }
        indicator.isHidden = false
        indicator.startAnimating()
        NetworkService.fetchUnsplashImages(with: searchTerm) { result in
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                switch result {
                case .success(let unsplashImages):
                    self.cityImages = unsplashImages
                    self.collectionView.reloadData()
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    @IBAction func navigateCarbonButtonTapped(_ sender: UIButton) {
        guard let carbonVC = mainStoryboard.instantiateViewController(withIdentifier: Constants.ViewControllers.carbonCalculateVC) as? CarbonCalculateViewController else { return }
        guard let searchTerm = searchTermForFetchingImages else { return }
        NetworkService.getAirports(with: "\(searchTerm) airport") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    carbonVC.toTextField.text = result.map { $0.iata ?? "" }.first
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        navigationController?.pushViewController(carbonVC, animated: true)
    }
    @IBAction func scrollButtonTapped(_ sender: UIButton) {
        
        let visibleItems: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for item in visibleItems {
            
            if minItem.row > (item as AnyObject).row {
                minItem = item as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row + 1, section: 0)
        self.collectionView.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
    }
    
    
    @IBAction func scrollLeftButtonTapped(_ sender: UIButton) {
        
        
        let visibleItems: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for item in visibleItems {
            
            if minItem.row > (item as AnyObject).row {
                minItem = item as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row - 1, section: 0)
        
        
        UIView.animate(withDuration: 1) {
            self.collectionView.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
        }
    }
    
    
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension SearchDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cityImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.searchDetailCollectionViewItemID, for: indexPath) as? CityImageCollectionViewCell else { return UICollectionViewCell() }
        item.cityImage = cityImages[indexPath.row]
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
            let storyboard = UIStoryboard(name: Constants.Storyboards.searchDetail, bundle: nil)
            guard let popupImageVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.popUpImageVC) as? PopupImageViewController else { return nil }
            popupImageVC.popupImage = self.cityImages[indexPath.item]
            return popupImageVC
        }, actionProvider: nil)
        return config
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let vc = animator.previewViewController else { return }
        animator.addCompletion {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Firebase Firestore Cloud Persistence
extension SearchDetailViewController {
    func saveData(locationName: String, imageURL: String) {
        let user = UserDefaults.standard.string(forKey: "user")
        var ref: DocumentReference? = nil
        ref = db.collection("favorites")
            .document(user!)
            .collection("places").addDocument(data: [
                "name": "\(locationName)",
                "imageURL": "\(imageURL)",
                "timestamp" : "\(Date())",
                "postalCode" : postalCodeLocation ?? ""
            ]) { err in
                
                if let err = err {
                    print("Error adding document: \(err)")
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.savingError)
                }
                else {
                    self.isFavorite = true
                    self.documentID = ref?.documentID
                    UIView.animate(withDuration: 1.0,
                                   delay: 0.5,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0.2,
                                   options: .transitionCrossDissolve,
                                   animations: {
                        
                        self.likeButton?.image = UIImage(systemName: "heart.fill")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            guard let savedVC = self.mainStoryboard.instantiateViewController(withIdentifier: Constants.ViewControllers.savedVC) as? SavedPlacesViewController else { return }
                            self.navigationController?.pushViewController(savedVC, animated: true)
                        }
                    },completion: nil)
                }
            }
    }
}


extension SearchDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.6, height: collectionView.frame.height)
    }
}

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
