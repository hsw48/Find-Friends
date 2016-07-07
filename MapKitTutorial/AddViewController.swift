//
//  AddViewController.swift
//  MapKitTutorial
//
//  Created by Thong Tran on 7/6/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit


class AddViewController: UIViewController {
    
    
    
    
    // Button Action
    @IBOutlet weak var doneOutlet: UIBarButtonItem!
    @IBAction func DoneButton(sender: AnyObject) {
        
        var meeting = ArrangeMeeting(nameOfTopic: topicTextField.text!, date: dateLabel.text! , location: addressTextField.text!)
        
    }
    @IBAction func pinAddress(sender: AnyObject) {
        if selectedPin == nil
        {
            alert(extendMessage: "Error", extendTitle: "Address has not been chosen")
        }
        else
        {
            
            let name = (selectedPin?.name)! ?? ""
            let streetNumber = (selectedPin?.subThoroughfare) ?? ""
            let streetName = (selectedPin?.thoroughfare) ?? ""
            let city = (selectedPin?.locality) ?? ""
            let state = (selectedPin?.administrativeArea) ?? ""
            let country = (selectedPin?.country) ?? ""
            
            let alertViewController = UIAlertController(title: "Do you want to mark \(name) as meeting location?", message: "\(streetNumber) \(streetName), \(city), \(state), \(country), \((selectedPin?.country)!) ", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            alertViewController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
                
                self.addressTextField.text = "\(name), \(streetNumber) \(streetName), \n \(city), \(state), \(country)"
            })
            )
            self.presentViewController(alertViewController, animated: true, completion: nil)
            alertViewController.view.tintColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    // Outlet
    @IBOutlet var scrollView: UIScrollView!
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var  locationManager = CLLocationManager()
   
    @IBOutlet weak var addressTextField: UILabel!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet var topicTextField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    var selectedPin:MKPlacemark? = nil
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil
    
    @IBAction func datePickerTapped(sender: AnyObject) {
        DatePickerDialog().show("Schedule the Meeting", doneButtonTitle: "Save", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            self.dateLabel.text = "\(date.convertToString())"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = 1000
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Place for the Meeting"
        searchBarView.addSubview((resultSearchController?.searchBar)!)
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
}

extension AddViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let UserLocation = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: UserLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        alert(extendMessage: "Erro", extendTitle: "Can't load location. Please Check Your Location Settings")
    }
    func alert(extendMessage dataMessage: String, extendTitle dataTitle: String){
        
        let alertController = UIAlertController(title: dataMessage, message: dataTitle, preferredStyle: .Alert)
        let Cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(Cancel)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
}



extension AddViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea,
            let addressNumber = placemark.subThoroughfare,
            let street = placemark.thoroughfare
        {
            annotation.subtitle = "\(addressNumber) \(street), \(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}


extension AddViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        return pinView
    }
}





