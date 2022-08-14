//
//  MapManager.swift
//  Places
//
//  Created by Егор Губанов on 22.07.2022.
//

import UIKit
import MapKit

class MapManager {
    
    private var scaleInMeters = 1000.0
    private var coordinate: CLLocationCoordinate2D?

    // MARK: - Internal methods
    
    func getDirections() {
        guard let coordinate = coordinate else {
            showAlert(title: "Nothing to show", message: "Couldn't find place coordinates")
            return
        }
        
        guard let url = URL(string: "yandexmaps://maps.yandex.ru/?pt=\(coordinate.longitude),\(coordinate.latitude)&z=17") else { return }
        UIApplication.shared.open(url)
    }
    
    func centerMap(locationManager: CLLocationManager, mapView: MKMapView) {
        guard let location = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: scaleInMeters, longitudinalMeters: scaleInMeters)
        
        mapView.setRegion(region, animated: true)
    }
    
    func setupPlacemark(from place: PlaceProtocol, in mapView: MKMapView) {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                print(location)
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemarks?.first?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.coordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocation(locationManager: CLLocationManager, mapView: MKMapView) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationPermissions(locationManager: locationManager, mapView: mapView)
        } else {
            showAlert(title: "Location services are disabled", message: "Please enable location in system preferences")
        }
    }
    
    func getAddress(mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Private methods
    
    private func checkLocationPermissions(locationManager: CLLocationManager, mapView: MKMapView) {
        switch locationManager.authorizationStatus {
        case .denied:
            showAlert(title: "Access to location services is denied", message: "Please change permissions in system preferences")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .restricted:
            showAlert(title: "Access to location services is restrcted", message: "Please change permissions in system preferences")
        @unknown default:
            print("Unknown case")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        
        alertWindow.rootViewController?.present(alertController, animated: true)
    }
}
