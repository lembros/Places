//
//  MapViewController.swift
//  Places
//
//  Created by Егор Губанов on 18.07.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let locationManager = CLLocationManager()           // Manager responsible for user location tracking
    private let annotationIdentifier = "annotationIdentifier"   // To init annotation from identifier
    private let pinImageView = UIImageView()
    private let mapManager = MapManager()

    // MARK: - Public properties
    
    var place: Place!
    var isShowingLocation = true    // two different modes for this ViewController: showing and choosing location

    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var getDirectionsButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        mapView.delegate = self
        locationManager.delegate = self
    
        setupScreen()
        
        if isShowingLocation {
            mapManager.setupPlacemark(from: place, in: mapView)
        } else {
            showPin()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        mapManager.checkLocation(locationManager: locationManager, mapView: mapView)
        if !isShowingLocation {
            mapManager.centerMap(locationManager: locationManager, mapView: mapView)
        }
    }
    
    // MARK: - IBActions
    @IBAction func centerAction() {
        mapManager.centerMap(locationManager: locationManager, mapView: mapView)
    }
    
    @IBAction func getDirectionsAction(_ sender: Any) {
        mapManager.getDirections()
    }
    
    // MARK: - Private functions
    
    private func setupScreen() {
        // Close button
        let closeButtonSize = CGSize(width: 30, height: 30)
        let cancelImage = UIImage(systemName: "xmark")
        
        closeButton.frame.size = closeButtonSize
        closeButton.setImage(cancelImage, for: .normal)
        closeButton.tintColor = .black
        
        // Center button
        let centerButtonSize = CGSize(width: 50, height: 50)
        let locationImage = UIImage(systemName: "location.fill")
        
        centerButton.frame.size = centerButtonSize
        centerButton.setImage(locationImage, for: .normal)
        centerButton.tintColor = .black
        
        // Location label
        currentLocationLabel.text = ""
        currentLocationLabel.numberOfLines = 0
        currentLocationLabel.isHidden = isShowingLocation
        
        // 'Done' button
        doneButton.isHidden = isShowingLocation
        
        // 'Get directions' button
        getDirectionsButton.isHidden = !isShowingLocation
        
        // To choose location correctly
        mapView.center = view.center
        
        if !isShowingLocation {
            showPin()
        }
    }
    
    private func showPin() {
        let pinIcon = UIImage(systemName: "mappin")!.scalePreservingAspectRatio(targetSize: CGSize(width: 40, height: 40))
        
        pinImageView.image = pinIcon
        pinImageView.frame.size = pinIcon.size
                
        let move = -pinIcon.size.height / 2
        pinImageView.center = mapView.center + CGPoint(x: 0, y: move)
        view.addSubview(pinImageView)
    }
}

// MARK: - Map View Deledate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationIdentifier
        ) as? MKPinAnnotationView ?? MKPinAnnotationView(
            annotation: annotation,
            reuseIdentifier: annotationIdentifier
        )
        
        annotationView.canShowCallout = true

        if let imageData = place.imageData {
            let size = annotationView.frame.size
            
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
            imageView.image = UIImage(data: imageData)
            imageView.layer.cornerRadius = 7
            imageView.clipsToBounds = true
            annotationView.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getAddress(mapView: mapView)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
                    
            let cityName = placemark.administrativeArea
            let streetName = placemark.thoroughfare
            let houseNumber = placemark.subThoroughfare
            
            guard let _ = streetName else { return }
            
            let addressArray = [cityName, streetName, houseNumber].map { $0 ?? "" }
            let address = addressArray.joined(separator: ", ")

            self.currentLocationLabel.text = address
        }
    }
}

// MARK: - LocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocation(locationManager: manager, mapView: mapView)
    }
}
