//
//  SearchDetailViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import UIKit
import CoreLocation

class SearchDetailViewController: UIViewController {
    // MARK: - Properties
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            getAirQualityForCity()
        }
    }
    var cityImages = [UnsplashImage]()
    var searchTermForFetchingImages: String?
    var postalCodeLocation: String?
    var likeButton : UIBarButtonItem?
    var cityImage: UIImage?
    let mainStoryboard = UIStoryboard(name: Constants.Storyboards.main, bundle: nil)
    
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
    @IBOutlet weak var scrollRightButton: UIButton!
    @IBOutlet weak var scrollLeftButton: UIButton!
    @IBOutlet weak var backgroundMain: UIView!
    @IBOutlet weak var airPollutionLabel: UILabel!
    @IBOutlet weak var airPollutionLabelBackground: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getImagesForCity()
        getAirQualityForCity()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLikeStatus()
    }
    // MARK: - Helpers
    func setupView() {
        indicator.isHidden = true
        scrollLeftButton.isHidden = true
        measurementDate.text = Date().dateToString()
        hideAirQStatusButtons()
        setupDesign()
        setupLikeButton()
        registerCollectionViewCell()
    }
    fileprivate func checkLikeStatus() {
        if let result = RealmManager.sharedInstance.get(SavedPlace.self) as? [SavedPlace] {
            if !result.filter({ $0.locationId == postalCodeLocation }).isEmpty {
                self.likeButton?.image = UIImage(systemName: "heart.fill")
            } else {
                self.likeButton?.image = UIImage(systemName: "heart")
            }
        }
    }
    fileprivate func hideAirQStatusButtons() {
        statusVeryPoorButton.isHidden = true
        statusPoorButton.isHidden = true
        statusModerateButton.isHidden = true
        statusFairButton.isHidden = true
        statusGoodButton.isHidden = true
    }
    fileprivate func setupDesign() {
        collectionView.layer.masksToBounds = true
        collectionView.layer.cornerRadius = 20
        cityImagesBackgroundView.layer.masksToBounds = false
        cityImagesBackgroundView.layer.cornerRadius = 20
        cityImagesBackgroundView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 0.7)
        airQDetailBackgroundView.layer.masksToBounds = false
        airQDetailBackgroundView.layer.cornerRadius = 20
        airQDetailBackgroundView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 0.7)
        calculateButton.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 0.7)
        backgroundMain.layer.cornerRadius = 30
        airPollutionLabelBackground.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 0.4)
        airPollutionLabelBackground.layer.cornerRadius = 20
        
    }
    fileprivate func registerCollectionViewCell() {
        collectionView.register(UINib(nibName: Constants.Identifiers.searchDetailCollectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.searchDetailCollectionViewItemID)
    }
    fileprivate func setupLikeButton() {
        likeButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(tapForLikeButton))
        likeButton?.tintColor = UIColor(named: "Green")
        navigationItem.rightBarButtonItem = likeButton
    }
    @objc func tapForLikeButton() {
        guard let title = title else { return }
        if let result = RealmManager.sharedInstance.get(SavedPlace.self) as? [SavedPlace] {
            if let place = result.filter({ $0.locationId == self.postalCodeLocation }).first {
                if place.isFavorite {
                    RealmManager.sharedInstance.remove(place)
                    self.checkLikeStatus()
                } else {
                    savePlaceToRealm(title)
                    navigateToSavedPlacesVC()
                }
            } else {
                savePlaceToRealm(title)
                navigateToSavedPlacesVC()
            }
        }
    }
    fileprivate func savePlaceToRealm(_ title: String) {
        let placeToSave = SavedPlace()
        placeToSave.locationName = title
        placeToSave.imageData = cityImage?.pngData()
        placeToSave.isFavorite = true
        if let coordinate = coordinate {
            placeToSave.latitude = coordinate.latitude
            placeToSave.longitude = coordinate.longitude
        }
        placeToSave.locationId = postalCodeLocation
        RealmManager.sharedInstance.set(placeToSave)
    }
    fileprivate func navigateToSavedPlacesVC() {
        DispatchQueue.main.async {
            guard let savedVC = self.mainStoryboard.instantiateViewController(withIdentifier: Constants.ViewControllers.savedVC) as? SavedPlacesViewController else { return }
            self.navigationController?.pushViewController(savedVC, animated: true)
        }
    }
    fileprivate func switchAirQStatus(airQList: [AirQList]) {
        guard let airQStatus = (airQList.compactMap({ $0.main.aqi })).first else { return }
        switch airQStatus {
        case 1:
            airPollutionLabel.text = "Low air pollution"
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = false
        case 2:
            airPollutionLabel.text = "Moderate air pollution"
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = false
            statusGoodButton.isHidden = true
        case 3:
            airPollutionLabel.text = "Unhealthy for sensitive groups"
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = false
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = true
        case 4:
            airPollutionLabel.text = "Very unhealthy air pollution"
            statusVeryPoorButton.isHidden = true
            statusPoorButton.isHidden = false
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = true
        case 5:
            airPollutionLabel.text = "Hazardous air pollution"
            statusVeryPoorButton.isHidden = false
            statusPoorButton.isHidden = true
            statusModerateButton.isHidden = true
            statusFairButton.isHidden = true
            statusGoodButton.isHidden = true
        default:
            break
        }
    }
    fileprivate func getAirQualityForCity() {
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
    fileprivate func getImagesForCity() {
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
                    self.getCellImage()
                    self.collectionView.reloadData()
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    fileprivate func getCellImage() {
        guard let imageURL = self.cityImages.first?.urls.regularURL else { return }
        NetworkService.fetchImage(with: imageURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.cityImage = image
                case .failure(let error):
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
    @IBAction func scrollRightButtonTapped(_ sender: UIButton) {
        self.collectionView.scrollToNextItem()
    }
    @IBAction func scrollLeftButtonTapped(_ sender: UIButton) {
        self.collectionView.scrollToPreviousItem()
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        scrollRightButton.isEnabled = (indexPath.item == cityImages.count - 1) ? false : true
    }
}
extension SearchDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.6, height: collectionView.frame.height)
    }
}
// MARK: - UIScrollViewDelegate
extension SearchDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        offsetX >= 50 ? scrollLeftButton.fadeIn(duration: 1.0) : scrollLeftButton.fadeOut(duration: 1.0)
    }
}
extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
