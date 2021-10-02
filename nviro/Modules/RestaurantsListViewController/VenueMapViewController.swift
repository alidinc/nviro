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
    
    // MARK: - Properties
    var annotations = [VenueAnnotation]()
    var venues = [Venue]()
    var place: SavedPlace?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMapView()
        getVenues()
        setupAnnotations(for: venues)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    
    // MARK: - Helpers
    fileprivate func setupView() {
        self.backgroundView.layer.cornerRadius = 30
        self.backgroundView.layer.masksToBounds = false
    }
    fileprivate func setupMapView() {
        self.mapView.delegate = self
        self.mapView.layer.cornerRadius = 20
    }
    
    fileprivate func setupAnnotations(for venues: [Venue]) {
        for venue in venues {
            let annotation = VenueAnnotation(
                title: venue.name,
                locationName: venue.categories.map({$0.shortName}).first,
                coordinate: CLLocationCoordinate2D(latitude: venue.location.lat, longitude: venue.location.lng))
            self.annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
        self.mapView.showAnnotations(annotations, animated: true)
    }
    
    fileprivate func getVenues() {
        if let place = place {
            self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), latitudinalMeters: 2500, longitudinalMeters: 2500), animated: true)
        
            if let locationName = place.locationName {
                print("LOCATION----------------------------------------------------------\(locationName)")
                NetworkService.getRestaurants(with: locationName) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let venues):
                            let venues = venues.map({$0.venue})
                            self.venues = venues
                        case .failure(let error):
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        }
                    }
                }
            }
        }
    }
}

extension VenueMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? VenueAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
}





//
//if let lastAnnotation = self.annotations.last {
//
//    let center = lastAnnotation.coordinate
//    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//    let region = MKCoordinateRegion(center: center, span: span)
//    self.venuesMapView.setRegion(region, animated: true)
//}
