//
//  RestaurantsViewController.swift
//  nviro
//
//  Created by Ali Dinç on 26/09/2021.
//

import Foundation
import UIKit


class RestaurantsListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var venues = [Venue]()
    var savedPlace: SavedPlace?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        guard let savedPlace = savedPlace else { return }
        getVenues(for: savedPlace)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
   
    // MARK: - Helpers
    fileprivate func setupView() {
        registerCell()
    }
    fileprivate func registerCell() {
        tableView.register(UINib(nibName: Constants.Identifiers.restaurantCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.restaurantCellId)
    }
    fileprivate func getVenues(for: SavedPlace) {
        guard let savedPlace = savedPlace,
              let placeName = savedPlace.locationName else { return }
        NetworkService.getRestaurants(with: placeName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let venues):
                    self.venues = venues
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}

extension RestaurantsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.restaurantCellId, for: indexPath) as? RestaurantTableViewCell else { return UITableViewCell() }
        let venue = venues[indexPath.row]
        cell.updateView(with: venue)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 7
    }
}
