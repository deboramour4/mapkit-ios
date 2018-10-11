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
    @IBOutlet weak var followSwitch: UISwitch!
    
    //My variables
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Functions to show an especific Area in map
        showMapArea(latitude: -3.743993, longitude: -38.535674)
        
        //Adding PointAnnotations to Map
        addPointTo(map: myMap,
                   in: CLLocationCoordinate2DMake(-3.742973, -38.478405),
                   withTitle: "Fortaleza, Ceará",
                   subtitle: "Esse é o lugar que eu venho todo santo dia",
                   pinImage: UIImage(named: "user"),
                   detailImage: UIImage(named: "city"))
        
        addPointTo(map: myMap,
                   in: CLLocationCoordinate2DMake(-3.842742, -38.391962),
                   withTitle: "Porto das Dunas, Ceará",
                   subtitle: "Esse é o lugar é bonito.",
                   pinImage: UIImage(named: "alert"),
                   detailImage: UIImage(named: "beach"))
        
        addPointTo(map: myMap,
                   in: CLLocationCoordinate2DMake(-3.852348, -38.678639),
                   withTitle: "Maracanaú, Ceará",
                   subtitle: "Esse é o lugar é aleatório",
                   pinImage: UIImage(named: "alert"),
                   detailImage: UIImage(named: "farm"))
        
        //Get user's location and show it in the map
        getUserLocation(myMap)
        
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
    
    func getUserLocation(_ map: MKMapView) {
        map.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateAreaOf(map: MKMapView, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        map.setCenter(center, animated: true)
    }
    
    func addPointTo(map: MKMapView, in coordinate: CLLocationCoordinate2D, withTitle title: String = "New point", subtitle: String = "", pinImage: UIImage? = nil, detailImage: UIImage? = nil) {
        
        //Create a custom point annotation to set a pin image and a detail image
        let point = CustomPointAnnotation()
        
        point.coordinate = coordinate
        point.title = title
        point.subtitle = subtitle
        
        if let _ = pinImage {
            point.pinImage = pinImage
        }
        if let _ = detailImage {
            point.detailImage = detailImage
        }
        
        map.addAnnotation(point)
    }
    
    @IBAction func createPointWithLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        
        let touchLocation = sender.location(in: myMap)
        let locationCoordinate = myMap.convert(touchLocation, toCoordinateFrom: myMap)
        addPointTo(map: myMap,
                   in: CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude),
                   pinImage: UIImage(named: "add"))
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //The map area follow the user location when the switch is on
        if followSwitch.isOn {
            let currentLocation = locations.last!

            let x : CLLocationDegrees = currentLocation.coordinate.latitude
            let y : CLLocationDegrees = currentLocation.coordinate.longitude

            updateAreaOf(map: self.myMap, latitude: x, longitude: y)
        }
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
        
        //Customize the view of the details
        customizeDetailView(annotationView!)
        
        return annotationView
    }


    func customizeDetailView(_ annotationView: MKAnnotationView) {
        //Change the image of the CustomPointAnnotation
        guard let customAnnotation = annotationView.annotation as? CustomPointAnnotation else {
            return
        }
        
        //Set the pinImage of the PointAnnotation
        annotationView.image = customAnnotation.pinImage
        
        if let customDetailImage = customAnnotation.detailImage {
        
            //Get width and height of the detailImage
            let width = customDetailImage.size.width
            let height = customDetailImage.size.height
            
            let customView = UIView()
            
            //Set constraints of the detailImage
            let views = ["customView": customView]
            customView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[customView(\(width/2))]", options: [], metrics: nil, views: views))
            customView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[customView(\(height/2))]", options: [], metrics: nil, views: views))
            
            //Add image to customView
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width/2, height: height/2))
            imageView.image = customAnnotation.detailImage
            customView.addSubview(imageView)
            
            annotationView.detailCalloutAccessoryView = customView
        }
    }

}
