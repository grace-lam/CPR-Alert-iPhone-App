//
//  CPRModel.swift
//  CPR Alert
//
//  Created by Grace Lam on 8/14/14.
//  Copyright (c) 2014 Grace Lam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class CPRModel {
    var firebase = Firebase(url:"***")
    
    var mapView:FirstViewController!
    var accountView:SecondViewController!
    
    var map:MKMapView!
    var myLocation:MKUserLocation!
    var user:Account!
    
    var alertMode = false
    var alerts:[[Double]] = []
    
    var alertLat:Double!
    var alertLong:Double!
    var alertTime:Double!
    
    var firstTimeViewingAlert = false
    var inRespondView = false
    var tokenData:String!
    
    init() {
    }
    
    func login(uid:String) {
        user = Account(id: uid)
    }
    
    func setPosition(position:CLLocationCoordinate2D) {
        if user != nil && user.location != nil {
            user.location.update(position)
        }
        else if user != nil {
            user.location = Location(user: user, location: position)
        }
    }
    
    func requestCPR() {
        if user != nil {
            user.requestCPR()
        }
    }
}
