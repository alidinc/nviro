//
//  NewCollectionViewCell.swift
//  nviro
//
//  Created by Ali Dinç on 05/09/2021.
//

import UIKit

protocol DeleteFromCollectionVCDelegate: SavedPlacesViewController {
    func deleteData(model: CollectionDataModel?, indexPath: Int)
}

class SavedCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var delegate: DeleteFromCollectionVCDelegate?
    var model : CollectionDataModel?
    var indexPath : Int?
    
    // MARK: - Outlets
    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.savedImage.contentMode = .scaleAspectFill
    }
    
    // MARK: - Helpers
    func configure(model: CollectionDataModel?, indexPath:Int) {
        guard let model = model else { return }
        self.model = model
        self.locationName.text = model.locationName
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
              let model = model else { return }
        delegate?.deleteData(model: model, indexPath: indexPath)
    }
}
