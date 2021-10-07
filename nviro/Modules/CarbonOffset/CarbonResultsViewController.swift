//
//  CarbonResultsViewController.swift
//  nviro
//
//  Created by Ali Dinç on 06/10/2021.
//

import Foundation
import UIKit

class CarbonResultsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundStackView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var carbonLabel: UILabel!
    @IBOutlet weak var treeLabel: UILabel!
    
    // MARK: - Properties
    var flightOffset: FlightOffset? {
        didSet {
            updateView()
        }
    }
    
    var selectedSegmentControlIndex: Int?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
    }
    
    // MARK: - Helpers
    func setupDesign() {
        self.backgroundView.layer.masksToBounds = false
        self.backgroundView.layer.cornerRadius = 20
        self.backgroundView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 10, color: .black, shadowOpacity: 0.75)
        self.backgroundStackView.layer.cornerRadius = 20
    }
    func updateView() {
        if let flightOffset = flightOffset {
            carbonLabel.text = flightOffset.data.carbonLoad
            distanceLabel.text = setDistanceLabel(for: flightOffset)
            treeLabel.text = setTreeOffsetLabel(for: flightOffset)
        }
    }
    func setTreeOffsetLabel(for flightOffset: FlightOffset) -> String {
        if selectedSegmentControlIndex == 1 {
            guard let treeQuantityString = flightOffset.data.requires.components(separatedBy: .whitespaces).first else { return "N/A" }
            guard let treeQuantityInt = Int(treeQuantityString) else { return "N/A" }
            return flightOffset.data.requires == "0 tree" ? "2 trees" : "\(treeQuantityInt * 2) trees"
        }
        return flightOffset.data.requires == "0 tree" ? "1 tree" : flightOffset.data.requires
    }
    func setDistanceLabel(for flightOffset: FlightOffset) -> String {
        if selectedSegmentControlIndex == 1 {
            guard let distanceString = flightOffset.data.distance.components(separatedBy: .whitespaces).first else { return "N/A" }
            guard let distanceInt = Int(distanceString) else { return "N/A" }
            return "\(distanceInt * 2) km"
        }
        return flightOffset.data.distance
    }
}
