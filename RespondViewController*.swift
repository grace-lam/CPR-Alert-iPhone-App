//
//  RespondViewController.swift
//  CPR Alert
//
//  Created by Grace Lam on 6/10/15.
//  Copyright (c) 2015 Grace Lam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import AddressBook

class RespondViewController:UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var backButton:UIButton!
    
    @IBOutlet var mapView:MKMapView!
    
    var locationManager: CLLocationManager!
    var userLoc: MKUserLocation = MKUserLocation()
    var pointAnnotation: MKPointAnnotation = MKPointAnnotation()
    var pointAnnotationAdded = false
    
    var cprLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var cprAnnotation:MKPointAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        backButton.layer.cornerRadius = 15
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = (UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )).CGColor
        
        if (model.alertMode == false) {
            self.performSegueWithIdentifier("respond", sender: self)
        }
        
        var locations:NSMutableArray = NSMutableArray()
        var time:Double = 0.0
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            
            locations.addObject(pointAnnotation)
        }
        model.user.rootFirebase.childByAppendingPath("responder").childByAppendingPath(model.user.uid).childByAppendingPath("alert").observeEventType(.ChildAdded, withBlock: { alertData in
            
            
                if let alertInfo = alertData.value as? NSDictionary {
                    
                    var cprLoc:CLLocationCoordinate2D = CLLocationCoordinate2D()
                    var cprAnn:MKPointAnnotation = MKPointAnnotation()
                    
                    if (alertInfo.objectForKey("latitude") != nil && alertInfo.objectForKey("longitude") != nil && alertInfo.objectForKey("time") != nil) {
                    
                    cprLoc.latitude = alertInfo.objectForKey("latitude") as! Double
                    cprLoc.longitude = alertInfo.objectForKey("longitude") as! Double
                    time = alertInfo.objectForKey("time") as! Double
                    
                    let date = NSDate(timeIntervalSince1970:time)
                    let dateFormatter = NSDateFormatter()
                    //To prevent displaying either date or time, set the desired style to NoStyle.
                    dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
                    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
                    dateFormatter.timeZone = NSTimeZone()
                    let localDate = dateFormatter.stringFromDate(date)
                    
                    cprAnn.subtitle = localDate
                    
                    cprAnn.coordinate = cprLoc
                    cprAnn.title = "CPR Needed Here"
                    
                    locations.addObject(cprAnn)
                    
                    self.cprLocation = cprLoc
                    self.cprAnnotation = cprAnn
                        
                    let region = MKCoordinateRegion(center: self.cprLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                    self.mapView.centerCoordinate = self.cprLocation
                    self.mapView.setRegion(region, animated: true)
                    
                    self.mapView.addAnnotations(locations as [AnyObject])
                    
                    self.mapView.selectAnnotation(self.cprAnnotation, animated: true)
                    self.pointAnnotationAdded = true
                        
                    }
                }
            
        })
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        model.inRespondView = true
    }
    
    @IBAction func centerMap(sender:UIButton) {
        if (pointAnnotationAdded) {
            self.mapView.centerCoordinate = cprLocation
            self.mapView.selectAnnotation(self.cprAnnotation, animated: true)
        }
    }
    
    @IBAction func returnToMap(sender:UIButton) {
        if (sender == backButton) {
            backButton.setTitleColor(UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 ), forState: UIControlState.Normal )
            backButton.backgroundColor = UIColor.whiteColor()
        }
        model.firstTimeViewingAlert = false
        self.performSegueWithIdentifier("respond", sender: self)
        
        model.inRespondView = false
    }
    
    @IBAction func changeColorOnTouch(sender:UIButton) {
        backButton.backgroundColor = UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )
        backButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: cprLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        pointAnnotation.coordinate = center
        pointAnnotation.title = "My Location"
        
        if (!pointAnnotationAdded) {
            
            
            self.mapView.centerCoordinate = cprLocation
            self.mapView.selectAnnotation(cprAnnotation, animated: true)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView (mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("cpr")
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "cpr")
            pinView.image = UIImage(named: "map_marker-new")
            pinView.canShowCallout = true
            
            pinView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            let annotation = view.annotation
            let coordinate:CLLocationCoordinate2D = annotation.coordinate
            var placemark:MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            var mapItem:MKMapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}