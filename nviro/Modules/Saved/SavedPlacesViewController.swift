//
//  FavoritesViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import FirebaseFirestore
import Firebase
import UIKit

class SavedPlacesViewController: UIViewController {
    
    // MARK: - Properties
    let db = Firestore.firestore()
    var savedPlaces = [SavedPlace?]()
    
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
        collectionView.layer.cornerRadius = 20
        collectionView.register(UINib(nibName: Constants.Identifiers.savedCollectionViewItemNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.savedCollectionViewItemID)
    }
    @objc func countLabelSwitch() {
        switch self.savedPlaces.count {
        case 0:
            self.countOfSavedPlacesLabel.text = "you don't have any saved places"
        case 1:
            self.countOfSavedPlacesLabel.text = "you have one saved place"
        default:
            self.countOfSavedPlacesLabel.text = "you have \(self.savedPlaces.count) saved places"
        }
    }
    
    @objc func snapshotListener() {
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        let user = UserDefaults.standard.string(forKey: "user")
        let ref = db.collection("favorites")
            .document(user!)
            .collection("places")
            .order(by: "timestamp", descending: true)
        
        ref.addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retrieving snapshot: \(error!)")
                return
            }
            self.savedPlaces.removeAll(keepingCapacity: false)
            
            for diff in snapshot.documents {
                var model = SavedPlace()
                
                for i in diff.data(){
                    if i.key == "name" {
                        model.locationName = i.value as? String ?? ""
                    }
                    if i.key == "imageURL"{
                        model.imageURL = i.value as? String ?? ""
                    }
                }
                model.id = diff.documentID
                self.savedPlaces.append(model)
                self.countLabelSwitch()
            }
            self.collectionView.reloadData()
            
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
        }
    }
}

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
        let storyboard = UIStoryboard(name: Constants.Storyboards.restaurantsList, bundle: nil)
        guard let restaurantsVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.restaurantsListVC) as? RestaurantsListViewController else { return }
        guard let place = savedPlaces[indexPath.row] else { return }
        restaurantsVC.savedPlace = place
        self.navigationController?.pushViewController(restaurantsVC, animated: true)
    }
}

extension SavedPlacesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 4)
    }
}

extension SavedPlacesViewController: DeleteFromCollectionVCDelegate {
    func deleteData(model: SavedPlace?, indexPath: Int) {
        let alert = UIAlertController(title: "Are you sure to delete this place?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            let user = UserDefaults.standard.string(forKey: "user")
            guard let modelId = model?.id else { return }
            self.db.collection("favorites").document(user!).collection("places").document(modelId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.countLabelSwitch()
                    self.collectionView.reloadData()
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}

