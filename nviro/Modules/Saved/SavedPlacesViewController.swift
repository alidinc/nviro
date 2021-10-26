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
    @IBOutlet weak var countLabelBackground: UIView!
    
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
        self.countLabelBackground.layer.cornerRadius = 12
        self.countLabelBackground.layer.masksToBounds = true
        self.countLabelBackground.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMinXMaxYCorner]
        collectionView.layer.cornerRadius = 30
        collectionView.register(UINib(nibName: Constants.Identifiers.savedCollectionViewItemNibName, bundle: nil),
                                forCellWithReuseIdentifier: Constants.Identifiers.savedCollectionViewItemID)
    }
    @objc func countLabelSwitch() {
        switch self.savedPlaces.count {
        case 0:
            self.countOfSavedPlacesLabel.text = "has no place"
        case 1:
            self.countOfSavedPlacesLabel.text = "has one place"
        default:
            self.countOfSavedPlacesLabel.text = "has \(self.savedPlaces.count) places"
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
        self.navigationController?.pushViewController(venuesMapVC, animated: true)
    }
    
}
extension SavedPlacesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 3.5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
// MARK: - DeleteFromCollectionVCDelegate
extension SavedPlacesViewController: DeleteFromCollectionVCDelegate {
    func deleteData(model: SavedPlace, indexPath: Int) {
        if let locationName = model.locationName {
            let alert = UIAlertController(title: "Are you sure to delete \(locationName) from your travel list?", message: nil, preferredStyle: .alert)
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
}

