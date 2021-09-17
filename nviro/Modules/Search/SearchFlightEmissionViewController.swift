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
    
    // MARK: - Outlets
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var calculateCarbonOffsetView: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var carbonResultsLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    func setupView() {
        resetLabelTexts()
        informationView.layer.cornerRadius = 20
        calculateCarbonOffsetView.layer.cornerRadius = 20
        calculateButton.layer.cornerRadius = 8
    }
    
    func resetLabelTexts() {
        departureLabel.text = ""
        destinationLabel.text = Constants.LabelTexts.carbonLabelInitialText
        carbonResultsLabel.text = ""
    }
    
    func setupLabelTexts() {
        guard let from = fromTextField.text, !from.isEmpty, from.count <= 4,
              let to = toTextField.text, !to.isEmpty, to.count <= 4 else { return }
    
        let carbonRequest = TravelRequest(passengers: 1, legs: [Leg(departure_airport: from, destination_airport: to)])
    
        getCarbonConsumption(request: carbonRequest)
        getAirports(searchTerm: from, for: departureLabel)
        getAirports(searchTerm: to, for: destinationLabel)
    }
    
    func getAirports(searchTerm: String, for label: UILabel) {
        NetworkService.getAirportCity(with: searchTerm) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let airport):
                    switch label {
                    case self.departureLabel:
                        self.departureLabel.text = "From \(airport.location), \(airport.country)"
                    case self.destinationLabel:
                        self.destinationLabel.text = "to \(airport.location), \(airport.country)"
                    default:
                        break
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    func getCarbonConsumption(request: TravelRequest) {
        NetworkService.carbonDetails(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let carbonResults):
                    self.carbonResultsLabel.text = "is \(carbonResults.data.attributes.distance_value)km has \(carbonResults.data.attributes.carbon_kg)kg of carbon consumption."
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
        hideKeyboard(fromTextField)
        hideKeyboard(toTextField)
    }
}

extension CarbonCalculateViewController: UITextFieldDelegate {
    fileprivate func hideKeyboard(_ textField: UITextField) {
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if fromTextField.text == "" && toTextField.text == "" {
            hideKeyboard(textField)
            resetLabelTexts()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if fromTextField.text == "" && toTextField.text == "" {
            hideKeyboard(textField)
            resetLabelTexts()
        }
        return true
    }
}
