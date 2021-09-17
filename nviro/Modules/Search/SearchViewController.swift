//
//  SearchViewController.swift
//  nviro
//
//  Created by Ali Dinç on 30/08/2021.
//

import FirebaseAuth
import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private let user = Auth.auth().currentUser
    private var coordinate: CLLocationCoordinate2D?
    private var nameVC: String?
    private var searchTerm: String?
    
    // MARK: - Outlets
    @IBOutlet weak var searchQuestionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchQuestionLabelView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Helpers
    fileprivate func setupSearchQuestionLabel() {
        if let user = user {
            guard let username = (user.email?.components(separatedBy: .punctuationCharacters))?.first?.capitalized else { return }
            searchQuestionLabel.text = "Hello \(username), \nwhere are you going?"
        }
    }
    fileprivate func setupNavigationBar() {
        let leavesView = UIImageView(image: UIImage(named: "leaves"))
        leavesView.contentMode = .scaleAspectFit
        navigationItem.titleView = leavesView
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    fileprivate func setupView() {
        searchTextField.delegate = self
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        searchQuestionLabelView.layer.cornerRadius = 20
        self.addShadow(to: searchQuestionLabelView)
        self.addShadow(to: searchTextField)
        setupNavigationBar()
        setupSearchQuestionLabel()
        
        self.tableView.register(UINib(nibName: Constants.Identifiers.searchTableViewCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.searchTableViewCellId)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.toDetailVC {
            guard let destination = segue.destination as? SearchDetailViewController else { return }
            guard let coordinate = coordinate,
                  let nameVC = nameVC,
                  let searchTerm = searchTerm else { return }
            destination.title = nameVC
            destination.coordinate = coordinate
            destination.searchTerm = searchTerm
        }
    }
}
// MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.searchTableViewCellId, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        let searchResult = searchResults[indexPath.row]
        cell.configure(locationName: searchResult.title, locationCountry: searchResult.subtitle)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchToSend = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: searchToSend)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else { return }
            self.nameVC = "\(searchToSend.title), \(searchToSend.subtitle)"
            self.coordinate = coordinate
            self.searchTerm = "\(searchToSend.title), \(searchToSend.subtitle)"
            self.performSegue(withIdentifier: Constants.Identifiers.toDetailVC, sender: nil)
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
