//
//  FirstViewController.swift
//  CPR Alert
//
//  Created by Grace Lam on 8/14/14.
//  Copyright (c) 2014 Grace Lam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet var cprButton:UIButton!
    @IBOutlet var centerButton:UIButton!
    @IBOutlet var alertButton:UIButton!
    
    var locationManager: CLLocationManager!
    var userLoc: MKUserLocation = MKUserLocation()
    var pointAnnotation: MKPointAnnotation = MKPointAnnotation()
    var pointAnnotationAdded = false
    
    var centerLoc: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        model.map = mapView
        model.myLocation = userLoc
        
        cprButton.layer.cornerRadius = 15
        cprButton.layer.borderWidth = 1
        cprButton.layer.borderColor = (UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )).CGColor
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.mapView.addAnnotation(pointAnnotation)
        }
        
        // TURN ON LOCATION SERVICES!
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
            var alert = UIAlertController(title: "Turn On Location Services to Allow \"CPR Alert\" to Determine Your Location", message: "This app requires tracking your location for requesting and receiving CPR alerts.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        Firebase(url:"***").observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                
                model.login(authData.uid)
                
            } else {
                // No user is logged in
                
                self.performSegueWithIdentifier("login", sender: self)
            }
        })
        
        if (model.user != nil && model.user.uid != nil) {
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
                Firebase(url: "***").childByAppendingPath("account").childByAppendingPath(model.user.uid).childByAppendingPath("location").setValue(true)
            } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
                Firebase(url: "***").childByAppendingPath("account").childByAppendingPath(model.user.uid).childByAppendingPath("location").setValue(false)
            }
            
            if (UIApplication.sharedApplication().currentUserNotificationSettings() == nil) {
                Firebase(url: "***").childByAppendingPath("account").childByAppendingPath(model.user.uid).childByAppendingPath("notifications").setValue(false)
            } else {
                Firebase(url: "***").childByAppendingPath("account").childByAppendingPath(model.user.uid).childByAppendingPath("notifications").setValue(true)
            }
        }
        
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if (model.alertMode && model.firstTimeViewingAlert && !model.inRespondView) {
            self.performSegueWithIdentifier("respond", sender: self)
        }
        
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        centerLoc = center
        
        pointAnnotation.coordinate = center
        pointAnnotation.title = "Current Location"
        
        if (!pointAnnotationAdded) {
            pointAnnotationAdded = true
            self.mapView.centerCoordinate = center
            self.mapView.selectAnnotation(pointAnnotation, animated: true)
            self.mapView.setRegion(region, animated: true)
        }
        
        model.setPosition(center)
        
        if model.alertMode == false {
            alertButton.alpha = 0.0
        } else {
            alertButton.alpha = 1.0
        }
    }
    
    @IBAction func centerMap(sender:UIButton) {
        self.mapView.centerCoordinate = centerLoc
    }
    
    @IBAction func seeAlert(sender:UIButton) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            if (model.alertMode) {
                self.performSegueWithIdentifier("respond", sender: self)
            } else {
                var alert = UIAlertController(title: "No Alerts!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { alertAction in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func changeColorOnTouch(sender:UIButton) {
        cprButton.backgroundColor = UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )
        cprButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func getCPR(sender:UIButton) {
        
        cprButton.setTitleColor(UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 ), forState: UIControlState.Normal )
        cprButton.backgroundColor = UIColor.whiteColor()
        
        confirmCPR()
    }
    
    func confirmCPR() {
        if Reachability.isConnectedToNetwork() == true {

            var alert = UIAlertController(title: "Confirm CPR Request", message: "Call 911 immediately. After selecting \"Confirm,\" this app will search for and notify nearby CPR responders.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel Request", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier("request", sender: self)
                model.requestCPR()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {

            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func mapView (mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
                if annotation is MKUserLocation {
                    //return nil so map view draws "blue dot" for standard user location
                    return nil
                }
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

