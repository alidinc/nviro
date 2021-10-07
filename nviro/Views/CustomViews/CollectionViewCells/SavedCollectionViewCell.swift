//
//  NewCollectionViewCell.swift
//  nviro
//
//  Created by Ali Dinç on 05/09/2021.
//

import UIKit

protocol DeleteFromCollectionVCDelegate: SavedPlacesViewController {
    func deleteData(model: SavedPlace, indexPath: Int)
}

class SavedCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var delegate: DeleteFromCollectionVCDelegate?
    var place : SavedPlace?
    var indexPath : Int?
    
    // MARK: - Outlets
    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var backgroundCell: UIView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.savedImage.contentMode = .scaleAspectFill
        self.stackView.layer.masksToBounds = true
        self.stackView.layer.cornerRadius = 20
        self.backgroundCell.layer.masksToBounds = false
        self.backgroundCell.layer.cornerRadius = 20
        self.backgroundCell.addShadow(xAxis: 0, yAxis: 2, shadowRadius: 4, color: .black, shadowOpacity: 0.75)
    }
    
    // MARK: - Helpers
    func configure(model: SavedPlace?, indexPath: Int) {
        guard let model = model else { return }
        self.place = model
        self.locationNameLabel.text = model.locationName
        self.indexPath = indexPath
        
        if let imageData = model.imageData {
            self.savedImage.image = UIImage(data: imageData)
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let indexPath = indexPath,
              let model = place else { return }
        delegate?.deleteData(model: model, indexPath: indexPath)
    }
}
