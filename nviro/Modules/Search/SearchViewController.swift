//
//  SearchViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private var coordinate: CLLocationCoordinate2D?
    private var nameVC: String?
    private var searchTermForImages: String?
    private var locationID: String?
    private var locationLat: Double?
    private var locationLon: Double?
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupBackgroundView() {
        backgroundView.layer.cornerRadius = 30
        backgroundView.layer.masksToBounds = false
        backgroundView.backgroundColor = UIColor(named: "Pine")
    }

    fileprivate func setupNavigationBar() {
        let leavesView = UIImageView(image: UIImage(named: "leaves.dark"))
        leavesView.contentMode = .scaleAspectFit
        navigationItem.titleView = leavesView
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    fileprivate func searchCompleterSetup() {
        searchTextField.delegate = self
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    fileprivate func registerTableViewCell() {
        self.tableView.register(UINib(nibName: Constants.Identifiers.searchTableViewCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.searchTableViewCellId)
    }
    
    fileprivate func setupSearchTextField() {
        self.searchTextField.textColor = UIColor.label
        self.searchTextField.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 0.12)
        self.searchTextField.backgroundColor = UIColor.secondarySystemBackground
        self.searchTextField.layer.cornerRadius = 20
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: " Where are you going?", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.darkGray,
            NSAttributedString.Key.backgroundColor : UIColor.clear])
    }
    
    fileprivate func setupView() {
        setupSearchTextField()
        searchCompleterSetup()
        setupBackgroundView()
        setupNavigationBar()
        registerTableViewCell()
    }
    
    // MARK: - Navigation
    func navigateToCityDetail() {
        let storyboard = UIStoryboard(name: Constants.Storyboards.searchDetail, bundle: nil)
        guard let cityDetailVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllers.cityDetail) as? SearchDetailViewController else { return }
        guard let coordinate = coordinate,
              let nameVC = nameVC,
              let postalCodeLocation = locationID,
              let searchTerm = searchTermForImages else { return }
        cityDetailVC.title = nameVC
        cityDetailVC.postalCodeLocation = postalCodeLocation
        cityDetailVC.coordinate = coordinate
        cityDetailVC.searchTermForFetchingImages = searchTerm
        self.navigationController?.pushViewController(cityDetailVC, animated: true)
    }
   
}
// MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.searchTableViewCellId, for: indexPath) as? SearchCell else { return UITableViewCell() }
        let searchResult = searchResults[indexPath.row]
        cell.configure(locationName: searchResult.title, locationCountry: searchResult.subtitle)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let searchToSend = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: searchToSend)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }
            self.nameVC = searchToSend.title
            self.coordinate = coordinate
            self.locationID = response?.mapItems[0].placemark.region?.identifier
            self.searchTermForImages = "\(searchToSend.title), \(searchToSend.subtitle)"
    
            self.navigateToCityDetail()
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchText = searchTextField.text else { return }
        searchCompleter.queryFragment = searchText
        if searchTextField.text == "" {
            searchCompleter.cancel()
            searchResults.removeAll(keepingCapacity: false)
            self.tableView.reloadData()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        searchTextField.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextField.resignFirstResponder()
        searchTextField.endEditing(true)
    }
}

// MARK: - MKLocalSearchDelegate
extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard completer.results.count != 0 else { return }
        searchResults = completer.results
        self.tableView.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.showAlert(title: "Error", message: Constants.ErrorMessages.locationSearch)
        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
    }
}
