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
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var flightClassSegment: UISegmentedControl!
    @IBOutlet weak var flightOptionSegment: UISegmentedControl!
    @IBOutlet weak var calculateStackView: UIStackView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var calculateBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundMain: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var resultsContainerView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupDesign() {
        calculateBackgroundView.layer.masksToBounds = true
        calculateBackgroundView.layer.cornerRadius = 20
        calculateStackView.layer.cornerRadius = 20
        calculateStackView.layer.masksToBounds = true
        
        backgroundMain.layer.cornerRadius = 30
        refreshButton.layer.cornerRadius = 12
        refreshButton.layer.masksToBounds = true
        refreshButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        calculateBackgroundView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 1)
        calculateButton.styleFilledButton(fillColor: UIColor(named: "Background")!, radius: 15, tintColor: .lightGray)
    }
    func setupView() {
        self.navigationController?.navigationBar.isTranslucent = true
        indicator.isHidden = true
        resultsContainerView.isHidden = true
        tableView.layer.cornerRadius = 20
        setupDesign()
    }
    
    func navigateToCarbonResultsVC(flightOffset: FlightOffset) {
        guard let cvc = children.last as? CarbonResultsViewController else { return }
        cvc.flightOffset = flightOffset
        cvc.selectedSegmentControlIndex = flightOptionSegment.selectedSegmentIndex
    }
    fileprivate func transition(to: UIView) {
        UIView.transition(with: to, duration: 1, options: .transitionFlipFromTop, animations: {
            self.tableView.isHidden = true
            self.hideKeyboard(self.fromTextField)
            self.hideKeyboard(self.toTextField)
            to.isHidden = false
        }, completion: nil)
    }
    
    func getFlightOffsetData(request: FlightOffsetRequest) {
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        NetworkService.flightOffset(flightOffsetRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let flightOffset):
                    self.navigateToCarbonResultsVC(flightOffset: flightOffset)
                    self.calculateBackgroundView.fadeOut2()
                    self.transition(to: self.resultsContainerView)
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                case .failure(let error):
                    self.showAlert(title: "Error", message: Constants.ErrorMessages.noResults)
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        guard let from = fromTextField.text, !from.isEmpty, from.count == 3,
              let to = toTextField.text, !to.isEmpty, to.count == 3 else {
                  self.showAlert(title: "Unrecognized airport code", message: "Please fill out text fields with your flight's departure and arrival airport codes(i.e Amsterdam == AMS).")
                  return
              }
        let flightOffsetRequest = FlightOffsetRequest(leg1: LegForFlight(originAirportCode: from, destinationAirportCode: to, travelClass: travelClass ?? "Economy"))
        getFlightOffsetData(request: flightOffsetRequest)
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
    @IBAction func refreshTapped(_ sender: UIButton) {
        UIView.transition(with: self.calculateBackgroundView, duration: 1, options: .transitionFlipFromBottom, animations: {
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            self.resultsContainerView.isHidden = true
            self.calculateBackgroundView.isHidden = false
            self.fromTextField.text?.removeAll()
            self.toTextField.text?.removeAll()
            self.fromTextField.endEditing(true)
            self.toTextField.endEditing(true)
        }, completion: nil)
    }
}
// MARK: - UITextFieldDelegate
extension CarbonCalculateViewController: UITextFieldDelegate {
    fileprivate func hideKeyboard(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if fromTextField.text == "" && toTextField.text == "" {
            hideKeyboard(textField)
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count ?? 0 >= 1 {
            NetworkService.getAirports(with: textField.text!) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let results):
                        self.airports = results
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
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
