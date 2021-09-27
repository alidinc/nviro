//
//  SearchFlightEmissionViewController.swift
//  nviro
//
//  Created by Ali Dinç on 06/09/2021.
//

import UIKit

class CarbonCalculateViewController: UIViewController {
    
    // MARK: - Properties
    var location: String?
    var travelClass: String?
    var airports = [Content]()
    
    // MARK: - Outlets
    @IBOutlet weak var calculateCarbonOffsetView: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var flightClassSegment: UISegmentedControl!
    @IBOutlet weak var flightOptionSegment: UISegmentedControl!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var emissionButton: UIButton!
    @IBOutlet weak var treesButton: UIButton!
    @IBOutlet weak var resultsStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupCornerRadius() {
        calculateCarbonOffsetView.layer.cornerRadius = 20
    }
    fileprivate func clearButtonTitles() {
        self.distanceButton.setTitle("0 km", for: .normal)
        self.emissionButton.setTitle("0 kg", for: .normal)
        self.treesButton.setTitle("0 tree", for: .normal)
    }
    func setupView() {
        indicator.isHidden = true
        resultsStackView.isHidden = true
        tableView.layer.cornerRadius = 20
        setupCornerRadius()
        clearButtonTitles()
    }
    func setupLabelTexts() {
        guard let from = fromTextField.text, !from.isEmpty,
              let to = toTextField.text, !to.isEmpty else { return }
        
        let flightOffsetRequest = FlightOffsetRequest(leg1: LegForFlight(originAirportCode: from, destinationAirportCode: to, travelClass: travelClass ?? "Economy"))
        getFlightOffsetData(request: flightOffsetRequest)
    }
    func setTreeOffsetLabel(for flightOffset: FlightOffset) -> String {
        if flightOptionSegment.selectedSegmentIndex == 1 {
            guard let treeQuantityString = flightOffset.data.requires.components(separatedBy: .whitespaces).first else { return "N/A" }
            guard let treeQuantityInt = Int(treeQuantityString) else { return "N/A" }
            return flightOffset.data.requires == "0 tree" ? "2 trees" : "\(treeQuantityInt * 2) trees"
        }
        return flightOffset.data.requires == "0 tree" ? "1 tree" : flightOffset.data.requires
    }
    func setDistanceLabel(for flightOffset: FlightOffset) -> String {
        if flightOptionSegment.selectedSegmentIndex == 1 {
            guard let distanceString = flightOffset.data.distance.components(separatedBy: .whitespaces).first else { return "N/A" }
            guard let distanceInt = Int(distanceString) else { return "N/A" }
            return "\(distanceInt * 2) km"
        }
        return flightOffset.data.distance
    }
    func getFlightOffsetData(request: FlightOffsetRequest) {
        indicator.isHidden = false
        indicator.startAnimating()
        NetworkService.flightOffset(flightOffsetRequest: request) { result in
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                switch result {
                case .success(let flightOffset):
                    self.emissionButton.setTitle(flightOffset.data.carbonLoad, for: .normal)
                    self.distanceButton.setTitle(self.setDistanceLabel(for: flightOffset), for: .normal)
                    self.treesButton.setTitle(self.setTreeOffsetLabel(for: flightOffset), for: .normal)
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        setupLabelTexts()
        tableView.fadeOut(duration: 0.4)
        hideKeyboard(fromTextField)
        hideKeyboard(toTextField)
        if fromTextField.text != "" && toTextField.text != "" {
            self.resultsStackView.fadeIn(duration: 0.4)
        }
    }
    @IBAction func flightClassChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            travelClass = "Economy"
        case 1:
            travelClass = "Business"
        default:
            travelClass = "Economy"
        }
    }
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        resultsStackView.fadeOut(duration: 0.4)
        tableView.fadeOut(duration: 0.4)
        fromTextField.text = ""
        toTextField.text = ""
        fromTextField.endEditing(true)
        toTextField.endEditing(true)
        clearButtonTitles()
    }
}
// MARK: - UITextFieldDelegate
extension CarbonCalculateViewController: UITextFieldDelegate {
    fileprivate func hideKeyboard(_ textField: UITextField) {
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if fromTextField.text == "" && toTextField.text == "" {
            hideKeyboard(textField)
        }
        
        hideKeyboard(textField)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        tableView.fadeIn(duration: 0.4)
        NetworkService.getAirports(with: textField.text!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    self.airports = results
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
// MARK: - UITableViewDelegate & UITableViewDataSource
extension CarbonCalculateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.airportsTableVCCellID, for: indexPath)
        let airport = airports[indexPath.row]
        cell.textLabel?.text = airport.name
        cell.detailTextLabel?.text = (airport.servedCity ?? "") + " , " + (airport.country?.name ?? "")
        cell.textLabel?.tintColor = .label
        cell.detailTextLabel?.tintColor = .secondaryLabel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let airport = airports[indexPath.row]
        if fromTextField.isFirstResponder {
            fromTextField.text = airport.iata
        } else if toTextField.isFirstResponder {
            toTextField.text = airport.iata
        }
        tableView.fadeOut(duration: 0.4)
    }
}


