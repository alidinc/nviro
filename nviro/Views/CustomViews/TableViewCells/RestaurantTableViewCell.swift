//
//  RestaurantCell.swift
//  nviro
//
//  Created by Ali Dinç on 26/09/2021.
//

import UIKit
import MapKit

class RestaurantTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var cellStackView: UIStackView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var venueCategoryLabel: UILabel!
    @IBOutlet weak var openInMapsButton: UIButton!
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    // MARK: - Properties
    var venue: Venue? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        addCornerRadius()
    }
    
    // MARK: - Helpers
    fileprivate func setupView() {
        addCornerRadius()
    }
    fileprivate func addCornerRadius() {
        cellStackView.layer.cornerRadius = 20
    }
    func updateView() {
        guard let venue = venue,
              let venueAddress = venue.location.address,
              let venueCategory = venue.categories.map({ $0.shortName }).first  else { return }
        
        self.venueNameLabel.text = venue.name
        self.venueAddressLabel.text = venueAddress
        self.venueCategoryLabel.text = venueCategory
    }
    
    // MARK: - Actions
    
    @IBAction func openInMapsButtonTapped(_ sender: UIButton) {
        
        
        
        
    }
    
    
}
