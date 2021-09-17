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
    var searchTerm: String?
    let mainStoryboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
    
    // MARK: - Outlets
    @IBOutlet weak var cityImagesBackgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var airQDetailBackgroundView: UIView!
    @IBOutlet weak var colorIndexImageView: UIImageView!
    @IBOutlet weak var carbonCalculateMessageView: UIView!
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
    @IBOutlet weak var planeButton: UIButton!
    @IBOutlet weak var coLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var no2Label: UILabel!
    @IBOutlet weak var oLabel: UILabel!
    @IBOutlet weak var so2Label: UILabel!
    @IBOutlet weak var measurementDate: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getImagesForCity()
        getAirQualityForCity()
        gestureRecognizerSetup()
    }
    
    // MARK: - Helpers
    fileprivate func airQStatusButtonsHide() {
        statusVeryPoorButton.isHidden = true
        statusPoorButton.isHidden = true
        statusModerateButton.isHidden = true
        statusFairButton.isHidden = true
        statusGoodButton.isHidden = true
    }
    fileprivate func setupCornerRadius() {
        cityImagesBackgroundView.layer.cornerRadius = 20
        airQDetailBackgroundView.layer.cornerRadius = 20
        carbonCalculateMessageView.layer.cornerRadius = 20
        collectionView.layer.cornerRadius = 20
    }
    
    @objc fileprivate func likeButtonTapped() {
        guard let title = title else { return }
        guard let imageURL = self.cityImages.first?.urls.regularURL.absoluteString else { return }
        self.saveData(locationName: title, imageURL: imageURL)
        
        guard let savedVC = mainStoryboard.instantiateViewController(withIdentifier: Constants.ViewControllers.savedVC) as? SavedPlacesViewController else { return }
        self.navigationController?.pushViewController(savedVC, animated: true)
    }
    
    func setupView() {
        indicator.isHidden = true
        measurementDate.text = Date().dateToString()
        airQStatusButtonsHide()
        setupCornerRadius()
        
        let likeButton = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(likeButtonTapped))
        likeButton.tintColor = UIColor(named: "Green")
        navigationItem.rightBarButtonItem = likeButton
        
        collectionView.register(UINib(nibName: Constants.Identifiers.searchDetailCollectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.searchDetailCollectionViewItemID)
        
        self.addShadow(to: airQDetailBackgroundView)
        self.addShadow(to: cityImagesBackgroundView)
        self.addShadow(to: carbonCalculateMessageView)
    }
    
    fileprivate func gestureRecognizerSetup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToCarbonCalculate))
        carbonCalculateMessageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func goToCarbonCalculate() {
        guard let carbonVC = mainStoryboard.instantiateViewController(withIdentifier: Constants.ViewControllers.carbonCalculateVC) as? CarbonCalculateViewController else { return }
        navigationController?.pushViewController(carbonVC, animated: true)
    }
    
    fileprivate func getAirQualityComponentsResults(airQList: [AirQList]) {
        guard let coResult = (airQList.compactMap { $0.components.co }).first else { return }
        guard let noResult = (airQList.compactMap { $0.components.no }).first else { return }
        guard let no2Result = (airQList.compactMap { $0.components.no2 }).first else { return }
        guard let oResult = (airQList.compactMap { $0.components.o3 }).first else { return }
        guard let so2Result = (airQList.compactMap { $0.components.so2}).first else { return }
        
        self.coLabel.text = "\(coResult)"
        self.noLabel.text = "\(noResult)"
        self.no2Label.text = "\(no2Result)"
        self.oLabel.text = "\(oResult)"
        self.so2Label.text = "\(so2Result)"
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
                    self.getAirQualityComponentsResults(airQList: airQList)
                    self.switchAirQStatus(airQList: airQList)
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    func getImagesForCity() {
        guard let searchTerm = searchTerm else { return }
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
        let ref = db.collection("favorites")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("places")
        
        ref.addDocument(data: [
            "name": "\(locationName)",
            "imageURL": "\(imageURL)",
            "timestamp" : "\(Date())"
        ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
                self.showAlert(title: "Error", message: Constants.ErrorMessages.savingError)
            }
        }
    }
}


extension SearchDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.6, height: collectionView.frame.height)
    }
}

