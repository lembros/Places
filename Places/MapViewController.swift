//
//  MapViewController.swift
//  Places
//
//  Created by Егор Губанов on 18.07.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let annotationIdentifier = "annotationIdentifier"
    var place: Place!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            let size = CGSize(width: 30, height: 30)
            let cancelImage = UIImage(named: "cancel")?.scalePreservingAspectRatio(targetSize: size)
            
            closeButton.frame.size = size
            closeButton.setImage(cancelImage, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        mapView.delegate = self
        
        setupPlacemark()
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
}

// MARK: - Map View Deledate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        annotationView?.canShowCallout = true

        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.image = UIImage(data: imageData)
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}
