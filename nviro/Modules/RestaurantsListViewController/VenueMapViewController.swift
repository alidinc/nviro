//
//  RestaurantsViewController.swift
//  nviro
//
//  Created by Ali Dinç on 26/09/2021.
//


import UIKit
import MapKit


class VenueMapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var annotations = [MKAnnotation]()
    var venues = [Venue]()
    var place: SavedPlace?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getVenues()
        //self.centerToLocation()
        setupView()
        setupMapView()
        
        print("HERE VENUES COUNT ...................................................")
        print(venues.count)
        
        
    }
    
    // MARK: - Helpers
    fileprivate func setupView() {
        self.backgroundView.layer.cornerRadius = 30
        self.backgroundView.layer.masksToBounds = false
        self.tableView.layer.cornerRadius = 20
        cellRegisterForTableView()
        mapView.layer.masksToBounds = false
        tableView.layer.masksToBounds = false
        mapView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 15, color: .black, shadowOpacity: 0.7)
        tableView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 8, color: .black, shadowOpacity: 0.7)
    }
    fileprivate func setupMapView() {
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.layer.cornerRadius = 20
    }
    fileprivate func cellRegisterForTableView() {
        self.tableView.register(UINib(nibName: Constants.Identifiers.restaurantCellNibName, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.restaurantCellId)
    }
    fileprivate func centerToLocation() {
        DispatchQueue.main.async {
            if let place = self.place {
                self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
            }
        }
        
    }
    fileprivate func getVenues() {
        if let place = place {
            if let locationName = place.locationName {
                print("LOCATION----------------------------------------------------------\(locationName)")
                DispatchQueue.main.async {
                    NetworkService.getVenues(with: locationName) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let venues):
                                self.venues = venues
                                self.setupAnnotations(for: venues)
                                self.tableView.reloadData()
                                 print("VENUE COUNT::::::::::::::::::\(venues.count)")
                            case .failure(let error):
                                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    fileprivate func setupAnnotations(for venues: [Venue]) {
        for venue in venues {
            let annotation = VenueAnnotation(
                title: venue.name,
                locationName: venue.location?.postalCode,
                coordinate: CLLocationCoordinate2D(latitude: venue.location?.lat ?? 0, longitude: venue.location?.lng ?? 0))
            self.annotations.append(annotation)
        }
        DispatchQueue.main.async {
            
            self.mapView.addAnnotations(self.annotations)
            self.mapView.showAnnotations(self.annotations, animated: true)
        }
    }
    
}

extension VenueMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? VenueAnnotation {
            let identifier = "pin"
            var view: MKMarkerAnnotationView
            if let dequeuedView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                dequeuedView.markerTintColor = UIColor(named: "PineMap")
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                view.rightCalloutAccessoryView?.tintColor = .systemGreen
                view.markerTintColor = UIColor(named: "PineMap")
            }
            return view
        }
        return nil
    }
}



extension VenueMapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.restaurantCellId, for: indexPath) as? RestaurantTableViewCell else { return UITableViewCell() }
        cell.venue = venues[indexPath.row]
        return cell
    }
}
