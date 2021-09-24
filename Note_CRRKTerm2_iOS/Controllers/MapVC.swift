//
//  MapVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-22.
//

import UIKit
import CoreData
import MapKit

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()

        if note != nil {
            displayLocation(latitude: note!.latitude, longitude: note!.longitude, title: note!.title!, subtitle: "Note saved here")
        }
    }
    
    // MARK: - Private method
    
    private func zoomToLocation(with coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
    
    private func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
        let deltaLatitude: CLLocationDegrees = 0.05
        let deltaLongitude: CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: deltaLatitude, longitudeDelta: deltaLongitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }

    // MARK: - IBAction
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
