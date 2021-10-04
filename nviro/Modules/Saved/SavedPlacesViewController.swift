//
//  FavoritesViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//


import UIKit
import RealmSwift

class SavedPlacesViewController: UIViewController {
    // MARK: - Properties
    var savedPlaces = [SavedPlace]() {
        didSet {
            self.countLabelSwitch()
            self.collectionView.reloadData()
        }
    }
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var countOfSavedPlacesLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        snapshotListener()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        snapshotListener()
    }
    // MARK: - Helpers
    func setupView() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        collectionView.layer.cornerRadius = 30
        collectionView.register(UINib(nibName: Constants.Identifiers.savedCollectionViewItemNibName, bundle: nil),
                                forCellWithReuseIdentifier: Constants.Identifiers.savedCollectionViewItemID)
    }
    @objc func countLabelSwitch() {
        switch self.savedPlaces.count {
        case 0:
            self.countOfSavedPlacesLabel.text = "there aren't any places"
        case 1:
            self.countOfSavedPlacesLabel.text = "there's one place"
        default:
            self.countOfSavedPlacesLabel.text = "there are \(self.savedPlaces.count) places"
        }
    }
    @objc func snapshotListener() {
        if let savedPlaces = RealmManager.sharedInstance.get(SavedPlace.self) as? [SavedPlace] {
            self.savedPlaces.removeAll()
            self.savedPlaces = savedPlaces
        }
    }
}
// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension SavedPlacesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPlaces.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeItem", for: indexPath) as? SavedCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(model: savedPlaces[indexPath.row], indexPath: indexPath.row)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: Constants.Storyboards.venuesList, bundle: nil)
        guard let venuesMapVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.venuesMapVC) as? VenueMapViewController else { return }
        let place = savedPlaces[indexPath.row]
        venuesMapVC.place = place
        
//        if let locationName = place.locationName {
//            DispatchQueue.main.async {
//                NetworkService.getVenues(with: locationName) { result in
//                    switch result {
//                    case .success(let venues):
//                         print("LOCATION FOR ANNOTATIONS --------------------------\(venues.map({$0.name}))")
//                        venuesMapVC.venues = venues
//                    case .failure(let error):
//                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
//                    }
//                }
//            }
//        }
    
        self.navigationController?.pushViewController(venuesMapVC, animated: true)
    }
}
extension SavedPlacesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 3.5)
    }
}
// MARK: - DeleteFromCollectionVCDelegate
extension SavedPlacesViewController: DeleteFromCollectionVCDelegate {
    func deleteData(model: SavedPlace, indexPath: Int) {
        let alert = UIAlertController(title: "Are you sure to delete this place?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            RealmManager.sharedInstance.remove(model)
            self.snapshotListener()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}

