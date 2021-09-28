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
    var venue: Venue? 
    
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
    func updateView(with venue: Venue) {
        self.venueNameLabel.text = venue.name
        
        if let venueCategory = venue.categories.map({ $0.shortName }).first {
            self.venueCategoryLabel.text = venueCategory
        }
    }
    
    // MARK: - Actions
    
    @IBAction func openInMapsButtonTapped(_ sender: UIButton) {
        
        
        
        
    }
    
    
}
