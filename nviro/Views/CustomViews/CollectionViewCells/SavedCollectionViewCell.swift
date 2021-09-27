//
//  NewCollectionViewCell.swift
//  nviro
//
//  Created by Ali Dinç on 05/09/2021.
//

import UIKit

protocol DeleteFromCollectionVCDelegate: SavedPlacesViewController {
    func deleteData(model: SavedPlace?, indexPath: Int)
}

class SavedCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var delegate: DeleteFromCollectionVCDelegate?
    var place : SavedPlace?
    var indexPath : Int?
    
    // MARK: - Outlets
    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.savedImage.contentMode = .scaleAspectFill
        self.layer.cornerRadius = 20
    }
    
    // MARK: - Helpers
    func configure(model: SavedPlace?, indexPath: Int) {
        guard let model = model else { return }
        self.place = model
        self.locationNameLabel.text = model.locationName
        self.indexPath = indexPath
        
        guard let urlImage = URL(string: model.imageURL ?? "") else { return }
        NetworkService.fetchImage(with: urlImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.savedImage.image = image
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let indexPath = indexPath,
              let model = place else { return }
        delegate?.deleteData(model: model, indexPath: indexPath)
    }
}
