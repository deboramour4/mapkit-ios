//
//  ViewController.swift
//  MapKitStudies
//
//  Created by Débora Oliveira on 10/10/18.
//  Copyright © 2018 Débora Oliveira. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    //Outlets from view
    @IBOutlet weak var myMap: MKMapView!
    
    //My variables
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myMap.showsUserLocation = true
        
        //Functions to answer the questions
        showMapArea(latitude: -3.743993, longitude: -38.535674)
        updateAreaOf(map: myMap, latitude: -3.943993, longitude: -38.535674)
        
        //Adding PointAnnotations to Map
        addPointTo(map: myMap, in: CLLocationCoordinate2DMake(-4.143993, -38.535674))
        addPointTo(map: myMap, in: CLLocationCoordinate2DMake(-3.743993, -38.535674), withTitle: "Eu to aqui", andSubtitle: "Esse é o lugar que eu venho todo santo dia", andImage: UIImage(named: "user"))
        
        addPointTo(map: myMap, in: CLLocationCoordinate2DMake(-4.143993, -38.935674), withTitle: "Um lugar perigoso", andSubtitle: "Esse é o lugar é estranho", andImage: UIImage(named: "alert"))
        
        getUserLocation()
        
        //Set delegates
        locationManager.delegate = self
        myMap.delegate = self
        
    }
    
    func showMapArea(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {

        let myCenterCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let myRegion = MKCoordinateRegion(center: myCenterCoordinate, span: mySpan)
        
        myMap.setRegion(myRegion, animated: true)
    }
    
    func getUserLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateAreaOf(map: MKMapView, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        map.setCenter(center, animated: true)

//        map.setRegion(MKCoordinateRegion(center: centerCoordinate, span: myMap.region.span), animated: true)
    }
    
    func addPointTo(map: MKMapView, in coordinate: CLLocationCoordinate2D, withTitle title: String = "New point", andSubtitle subtitle: String = "", andImage image: UIImage? = nil) {
        let point = CustomPointAnnotation()
        point.coordinate = coordinate
        point.title = title
        point.subtitle = subtitle
        if let _ = image {
            point.image = image
        }
        map.addAnnotation(point)
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        
        let x : CLLocationDegrees = currentLocation.coordinate.latitude
        let y : CLLocationDegrees = currentLocation.coordinate.longitude
        
        updateAreaOf(map: self.myMap, latitude: x, longitude: y)
        
        print(locations)
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationID = "annotationID"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        //Get the custom image set in CustomPointAnnotation
        if let customAnnotation = annotation as? CustomPointAnnotation {
            annotationView!.image = customAnnotation.image
        }
        
        return annotationView
    }
    
}
