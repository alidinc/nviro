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
    var dataArray = [CollectionDataModel?]()
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var countOfSavedPlacesLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        snapshotListener()
    }
    
    // MARK: - Helpers
    func setupView() {
        collectionView.layer.cornerRadius = 20
        collectionView.register(UINib(nibName: Constants.Identifiers.savedCollectionViewItemNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Identifiers.savedCollectionViewItemID)
    }
    
    func snapshotListener() {
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        
        let ref = db.collection("favorites")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("places")
            .order(by: "timestamp", descending: true)
        
        ref.addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retrieving snapshot: \(error!)")
                return
            }
            self.dataArray.removeAll(keepingCapacity: false)
            
            for diff in snapshot.documents {
                var model = CollectionDataModel()
                
                for i in diff.data(){
                    if i.key == "name" {
                        model.locationName = i.value as? String ?? ""
                    }
                    if i.key == "imageURL"{
                        model.imageURL = i.value as? String ?? ""
                    }
                }
                model.id = diff.documentID
                self.dataArray.append(model)
                self.countOfSavedPlacesLabel.text = "You have \(self.dataArray.count) saved places."
                if self.dataArray.count == 0 {
                    self.countOfSavedPlacesLabel.text = "You don't have any saved places."
                }
            }
            self.collectionView.reloadData()
            
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
        }
    }
}

extension SavedPlacesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeItem", for: indexPath) as? SavedCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(model: dataArray[indexPath.row], indexPath: indexPath.row)
        cell.delegate = self
        return cell
    }
}

extension SavedPlacesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height / 4)
    }
}

extension SavedPlacesViewController: DeleteFromCollectionVCDelegate {
    func deleteData(model: CollectionDataModel?, indexPath:Int) {
        db.collection("favorites").document(Auth.auth().currentUser?.uid ?? "").collection("places").document(model?.id ?? "").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
//                self.dataArray.remove(at: indexPath)
//                self.collectionView.reloadData()
            }
        }
    }
}

