//
//  SearchFlightEmissionViewController.swift
//  nviro
//
//  Created by Ali Dinç on 06/09/2021.
//

import UIKit
import SafariServices

class CarbonCalculateViewController: UIViewController {
    
    // MARK: - Properties
    var location: String?
    
    // MARK: - Outlets
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var calculateCarbonOffsetView: UIView!
    @IBOutlet weak var treePurchaseInformationView: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var carbonResultsLabel: UILabel!
    @IBOutlet weak var departureView: UIView!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var carbonResultsView: UIView!
    @IBOutlet weak var carbonResultsFullBackgroundView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupCornerRadius() {
        informationView.layer.cornerRadius = 20
        calculateCarbonOffsetView.layer.cornerRadius = 20
        calculateButton.layer.cornerRadius = 8
        departureView.layer.cornerRadius = 15
        destinationView.layer.cornerRadius = 15
        carbonResultsView.layer.cornerRadius = 15
        treePurchaseInformationView.layer.cornerRadius = 20
    }
    
    fileprivate func setupTapGestureForSafari() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInSafari))
        treePurchaseInformationView.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func openInSafari() {
        if let url = URL(string: "https://ecologi.com/") {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
            }
    }
    
    fileprivate func setupNavigationBar() {
        let leavesView = UIImageView(image: UIImage(named: "leaves"))
        leavesView.contentMode = .scaleAspectFit
        navigationItem.titleView = leavesView
    }
    
    func setupView() {
        indicator.isHidden = true
        carbonResultsFullBackgroundView.isHidden = true
        setupCornerRadius()
        setupNavigationBar()
        setupTapGestureForSafari()
        self.addShadow(to: informationView)
        self.addShadow(to: treePurchaseInformationView)
    }
    
    func setupLabelTexts() {
        guard let from = fromTextField.text, !from.isEmpty, from.count <= 4,
              let to = toTextField.text, !to.isEmpty, to.count <= 4 else { return }
    
        let flightOffsetRequest = FlightOffsetRequest(leg1: LegForFlight(originAirportCode: from, destinationAirportCode: to))
        getFlightOffsetData(request: flightOffsetRequest)
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
    
    func setTreeOffset(flightOffset: FlightOffset) -> String {
        return flightOffset.data.requires == "0 tree" ? "1 tree" : flightOffset.data.requires
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
                    self.carbonResultsLabel.text = "is \(flightOffset.data.distance) has \(flightOffset.data.carbonLoad) of carbon consumption. Your carbon offset is \(self.setTreeOffset(flightOffset: flightOffset))."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showAlertForCarbonResults(results: flightOffset)
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    func showAlertForCarbonResults(results: FlightOffset) {
        guard let carbonString = results.data.carbonLoad.components(separatedBy: .whitespaces).first else { return }
        guard let carbonInt = Int(carbonString) else { return }
        switch carbonInt {
        case 0...100:
            self.showAlert(title: "Excessive carbon emission", message: "You might try to find other travel options.")
        case 100...2000:
            self.showAlert(title: "Excessive carbon emission", message: "Taking one return flight generates more CO2 than citizens of some countries produce in a year. Please try other travel options.")
        default:
            self.showAlert(title: "Excessive carbon emission", message: "Taking one return flight generates more CO2 than citizens of some countries produce in a year. Please try other travel options.")
        }
    }
    
    // MARK: - Actions
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        setupLabelTexts()
        carbonResultsFullBackgroundView.isHidden = false
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
            carbonResultsFullBackgroundView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if fromTextField.text == "" && toTextField.text == "" {
            hideKeyboard(textField)
            carbonResultsFullBackgroundView.isHidden = true
        }
        return true
    }
}
