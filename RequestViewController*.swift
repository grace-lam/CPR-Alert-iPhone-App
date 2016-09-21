//
//  RequestViewController.swift
//  CPR Alert
//
//  Created by Grace Lam on 6/10/15.
//  Copyright (c) 2015 Grace Lam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class RequestViewController:UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var backButton:UIButton!
    
    @IBOutlet var mapView:MKMapView!
    
    var locationManager: CLLocationManager!
    var userLoc: MKUserLocation = MKUserLocation()
    var pointAnnotation: MKPointAnnotation = MKPointAnnotation()
    var pointAnnotationAdded = false
    
    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var requestAnnotation:MKPointAnnotation = MKPointAnnotation()
    
    var locations:NSMutableArray = NSMutableArray()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        backButton.layer.cornerRadius = 15
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = (UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )).CGColor
        
        model.user.rootFirebase.childByAppendingPath("cpr").childByAppendingPath(model.user.uid).childByAppendingPath("responders").observeEventType(.ChildAdded, withBlock: { alertData in
            
            
            
            self.requestLocation.latitude = model.alertLat
            self.requestLocation.longitude = model.alertLong
            
            let region = MKCoordinateRegion(center: self.requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            self.mapView.centerCoordinate = self.requestLocation
            self.mapView.setRegion(region, animated: true)
            
            let date = NSDate(timeIntervalSince1970:model.alertTime)
            let dateFormatter = NSDateFormatter()
            //To prevent displaying either date or time, set the desired style to NoStyle.
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let localDate = dateFormatter.stringFromDate(date)
            
            self.requestAnnotation.subtitle = localDate
            self.requestAnnotation.coordinate = self.requestLocation
            self.requestAnnotation.title = "Getting CPR Here"
            
            self.locations.addObject(self.requestAnnotation)
            
            
                if let responderInfo = alertData.value as? NSDictionary {
                    
                    var responderLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
                    var responderAnnotation:MKPointAnnotation = MKPointAnnotation()
                    
                    if (responderInfo.objectForKey("latitude") != nil && responderInfo.objectForKey("longitude") != nil) {
                        responderLocation.latitude = responderInfo.objectForKey("latitude") as! Double
                        responderLocation.longitude = responderInfo.objectForKey("longitude") as! Double
                    }
                    
                    responderAnnotation.coordinate = responderLocation
                    responderAnnotation.title = "CPR Responder Alerted"
                    self.locations.addObject(responderAnnotation)
                }
            
            self.mapView.addAnnotations(self.locations as [AnyObject])
            
            self.mapView.selectAnnotation(self.requestAnnotation, animated: true)
            self.pointAnnotationAdded = true
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
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
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func centerMap(sender:UIButton) {
        if (!pointAnnotationAdded) {
            self.requestLocation.latitude = model.alertLat
            self.requestLocation.longitude = model.alertLong
            
            let region = MKCoordinateRegion(center: self.requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            self.mapView.centerCoordinate = self.requestLocation
            self.mapView.setRegion(region, animated: true)
            
            let date = NSDate(timeIntervalSince1970:model.alertTime)
            let dateFormatter = NSDateFormatter()
            //To prevent displaying either date or time, set the desired style to NoStyle.
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let localDate = dateFormatter.stringFromDate(date)
            
            self.requestAnnotation.subtitle = localDate
            self.requestAnnotation.coordinate = self.requestLocation
            self.requestAnnotation.title = "Getting CPR Here"
            
            locations.addObject(self.requestAnnotation)
            
            self.mapView.addAnnotations(locations as [AnyObject])
            self.mapView.selectAnnotation(self.requestAnnotation, animated: true)
            
        } else {
            self.mapView.centerCoordinate = requestLocation
            self.mapView.selectAnnotation(self.requestAnnotation, animated: true)
        }
    }

    
    @IBAction func returnToMap(sender:UIButton) {
        if (sender == backButton) {
            backButton.setTitleColor(UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 ), forState: UIControlState.Normal )
            backButton.backgroundColor = UIColor.whiteColor()
        }
        
        self.performSegueWithIdentifier("request", sender: self)
    }
    
    
    @IBAction func changeColorOnTouch(sender:UIButton) {
        backButton.backgroundColor = UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )
        backButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
}