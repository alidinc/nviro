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
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var backgroundTableView: UIView!
    @IBOutlet weak var backgroundMapView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLabelBackground: UIView!
    
    // MARK: - Properties
    var annotations = [MKAnnotation]()
    var venues = [Venue]()
    var place: SavedPlace?
    var isTapped = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getVenues()
        setupView()
        setupMapView()
    }
    
    // MARK: - Helpers
    fileprivate func setupView() {
        setupDesign()
        getTitleForLocation()
        cellRegisterForTableView()
    }
    fileprivate func setupDesign() {
        self.backgroundView.layer.cornerRadius = 30
        self.backgroundView.layer.masksToBounds = true
        self.locationLabelBackground.layer.cornerRadius = 10
        self.locationLabelBackground.layer.masksToBounds = true
        self.locationLabelBackground.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.tableView.layer.cornerRadius = 20
        mapView.layer.masksToBounds = true
        tableView.layer.masksToBounds = true
        backgroundView.addShadow(xAxis: 0, yAxis: 4, shadowRadius: 15, color: .black, shadowOpacity: 0.7)
    }
    fileprivate func setupMapView() {
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = true
        self.mapView.mapType = .standard
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
    fileprivate func getTitleForLocation() {
        if let placeLocation = place?.locationName {
            self.locationLabel.text = "\(placeLocation)"
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
    @IBAction func selectedCallOutButtonTapped(_ sender: UIButton) {
        
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
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let venueForAnnotation = view.annotation as? VenueAnnotation {
            let location = CLLocation(latitude: venueForAnnotation.coordinate.latitude, longitude: venueForAnnotation.coordinate.longitude)
            if let locationName = venueForAnnotation.locationName {
                self.openInMaps(location, locationName)
            }
        }
    }
}

extension VenueMapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.restaurantCellId, for: indexPath) as? VenueCell else { return UITableViewCell() }
        cell.venue = venues[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height / 4
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = venues[indexPath.row]
        let latitude = venue.location?.lat ?? 0
        let longitude = venue.location?.lng ?? 0
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.selectAnnotation(annotations[indexPath.row], animated: true)
    }
    fileprivate func openInMaps(_ requestLocation: CLLocation, _ itemName: String) {
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkArray, error) in
            if let placemarks = placemarkArray {
                if placemarks.count > 0 {
                    let newPlacemark = MKPlacemark(placemark: placemarks[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = itemName
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
}
