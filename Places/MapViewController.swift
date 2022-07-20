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
    private var scaleInMeters = 1000.0

    // MARK: - Public properties
    
    var place: Place!
    var isShowingLocation = true    // two different modes for this ViewController: showing and choosing location
    let pinImageView = UIImageView()

    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    
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
        
        // To choose location correctly
        mapView.center = view.center
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        mapView.delegate = self
        locationManager.delegate = self
    
        setupScreen()
        
        if isShowingLocation {
            setupPlacemark()
        } else {
            showPin()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        checkLocation()
        if !isShowingLocation {
            centerAction()
        }
    }
    
    // MARK: - IBActions
    @IBAction func centerAction() {
        guard let location = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: scaleInMeters, longitudinalMeters: scaleInMeters)
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Private functions
    
    private func showPin() {
        let pinIcon = UIImage(systemName: "mappin")!.scalePreservingAspectRatio(targetSize: CGSize(width: 40, height: 40))
        
        pinImageView.image = pinIcon
        pinImageView.frame.size = pinIcon.size
                
        let move = -pinIcon.size.height / 2
        pinImageView.center = mapView.center + CGPoint(x: 0, y: move)
        view.addSubview(pinImageView)
    }
    
    private func checkLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationPermissions()
        } else {
            showAlert()
        }
    }
    
    private func checkLocationPermissions() {
        switch locationManager.authorizationStatus {
        case .denied:
            showAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .restricted:
            showAlert()
        @unknown default:
            print("Unknown case")
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Location Services are turned off", message: "Please enable them in settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                print(location)
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemarks?.first?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func getAddress(from mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
            
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
            imageView.image = UIImage(data: imageData)
            imageView.layer.cornerRadius = 7
            imageView.clipsToBounds = true
            annotationView.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getAddress(from: mapView)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
                                
            let streetName = placemark.thoroughfare
            let houseNumber = placemark.subThoroughfare
                
            var address = ""
                
            switch (streetName, houseNumber) {
            case (nil, nil): break
            case (let street, nil): address = street!
            default: address = streetName! + ", " + houseNumber!
            }
            
            self.currentLocationLabel.text = address
        }
    }
}

// MARK: - LocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
