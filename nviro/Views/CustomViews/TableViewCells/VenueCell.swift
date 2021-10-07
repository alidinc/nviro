//
//  RestaurantCell.swift
//  nviro
//
//  Created by Ali Dinç on 26/09/2021.
//

import UIKit
import MapKit

class VenueCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueCategoryLabel: UILabel!
    @IBOutlet weak var rankingStarLabel: UILabel!
    
    // MARK: - Properties
    var venue: Venue? {
        didSet {
            updateView()
        }
    }
    // MARK: - Helpers
    fileprivate func updateView() {
        if let venue = venue {
            venueNameLabel.text = venue.name
            let categories = venue.categories.map({$0})
            guard let categoryName = categories.map({$0.name}).first else { return }
            venueCategoryLabel.text = categoryName
        }
    }
}
