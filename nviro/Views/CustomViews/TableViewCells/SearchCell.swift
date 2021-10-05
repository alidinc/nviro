//
//  LocationSearchTableViewCell.swift
//  nviro
//
//  Created by Ali Dinç on 06/09/2021.
//

import UIKit

class SearchCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    // MARK: - Helpers
    func configure(locationName: String, locationCountry: String) {
        cityLabel.text = locationName
        countryLabel.text = locationCountry
    }
}
