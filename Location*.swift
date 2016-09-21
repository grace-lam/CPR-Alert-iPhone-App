//
//  Location.swift
//  CPR Alert
//
//  Created by Grace Lam on 2/20/15.
//  Copyright (c) 2015 Grace Lam. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Location {
    var latitude:Double!
    var longitude:Double!
    var cacheLatitude:Double = 10000
    var cacheLongitude:Double = 10000
    
    var loc:CLLocationCoordinate2D!
    var saveLocation = false
    var hasLocation = false
    
    var user:Account!
    
    init(user:Account, location:CLLocationCoordinate2D) {
        self.user = user
        self.update(location)
    }
    
    func alert(location:Firebase) {
        model.alertLat = latitude
        model.alertLong = longitude
        model.alertTime = NSDate().timeIntervalSince1970
        
        location.setValue(["latitude": latitude, "longitude": longitude, "time": model.alertTime])
    }
    
    func save(location:Firebase) {
        
        if latitude != nil && longitude != nil {
            
            if latitude != cacheLatitude && longitude != cacheLongitude {
                location.childByAppendingPath("latitude").setValue(latitude)
                location.childByAppendingPath("longitude").setValue(longitude)
                location.childByAppendingPath("time").setValue(NSDate().timeIntervalSince1970)
                location.childByAppendingPath("distance").setValue(user.distance)
                location.childByAppendingPath("token").setValue(model.tokenData)
                
                cacheLatitude = latitude
                cacheLongitude = longitude
            }
            else {
                location.childByAppendingPath("time").setValue(NSDate().timeIntervalSince1970)
                location.childByAppendingPath("distance").setValue(user.distance)
                location.childByAppendingPath("token").setValue(model.tokenData)
            }
        }
    }
    
    
    func update(location:CLLocationCoordinate2D) {
        loc = location
        
        self.latitude = loc.latitude
        self.longitude = loc.longitude
        
        hasLocation = true
        
        if (user.cprState != nil) {
            saveLocation = user.cprState
        }
        
        if (saveLocation) {
            self.save(user.rootFirebase.childByAppendingPath("responder").childByAppendingPath(user.uid))
        }
        
        Firebase(url: "***").childByAppendingPath("responder").childByAppendingPath(user.uid).childByAppendingPath("alert").observeEventType(.Value, withBlock: { alertData in
            if (alertData.value is NSNull) {
                model.alertMode = false
            } else {
                model.alertMode = true
            }
        })
    }
}