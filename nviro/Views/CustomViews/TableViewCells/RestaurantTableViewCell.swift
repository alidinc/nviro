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
    @IBOutlet weak var venueCategoryLabel: UILabel!
    @IBOutlet weak var openInMapsButton: UIButton!

    // MARK: - Properties
    var venue: Venue? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Helpers
    fileprivate func setupView() {
        self.layer.masksToBounds = true
        cellStackView.layer.cornerRadius = 20
    }
    fileprivate func updateView() {
        if let venue = venue {
            venueNameLabel.text = venue.name
            let categories = venue.categories.map({$0})
            guard let categoryName = categories.map({$0.name}).first else { return }
            
            venueCategoryLabel.text = categoryName
        }
    }
}
