//
//  Account.swift
//  CPR Alert
//
//  Created by Grace Lam on 2/20/15.
//  Copyright (c) 2015 Grace Lam. All rights reserved.
//

import Foundation

class Account {
    var uid:String!
    var distance:Double!
    var locState:Bool!
    var cprState:Bool!
    var location:Location!
    var time:Double!
    
    var rootFirebase = Firebase(url: "***")
    var firebase:Firebase!
    
    init(id:String) {
        self.uid = id
        self.firebase = rootFirebase.childByAppendingPath("account").childByAppendingPath(id)
        updateAccount()
    }
    
    func updateAccount() {
        readCPRState()
        readDistance()
    }
    
    func readDistance() {
        self.firebase.childByAppendingPath("distance").observeEventType(.Value, withBlock: { distanceData in
            if let dist = distanceData.value as? Double {
                self.distance = dist
                if model.accountView != nil {
                    model.accountView.alertDistanceControl.selectedSegmentIndex = Int(self.distance)
                }
            }
            else {
                self.firebase.childByAppendingPath("distance").setValue(2)
                self.distance = 2
            }
        })
    }
    
    func readCPRState() {
        self.firebase.childByAppendingPath("certified").observeEventType(.Value, withBlock: { cprData in
            if let cpr = cprData.value as? Bool {
                self.cprState = cpr
                if model.accountView != nil {
                    model.accountView.certifiedSwitch.setOn(self.cprState, animated: true)
                }
            }
            else {
                self.firebase.childByAppendingPath("certified").setValue(false)
                self.cprState = false
            }
        })
    }
    
    func setMaxDistance(index:Int) {
        self.distance = Double(index)
        self.firebase.childByAppendingPath("distance").setValue(distance)
        
        if self.cprState != nil && self.cprState == true {
            self.rootFirebase.childByAppendingPath("responder").childByAppendingPath(self.uid).childByAppendingPath("distance").setValue(self.distance)
        }
    }
    
    func setCPRState(on:Bool) {
        self.cprState = on
        self.firebase.childByAppendingPath("certified").setValue(on)
        
        if (self.cprState == true) {
            if on {
                // Register for Push Notitications, if running iOS 8
                if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
                    
                    let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
                    let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
                    
                    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                    
                    
                } else {
                    // Register for Push Notifications before iOS 8
                    UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
                }
            }
            
        } else {
            
            self.rootFirebase.childByAppendingPath("responder").childByAppendingPath(self.uid).removeValue()
        }
    }
    
    func requestCPR() {
        
        if self.location != nil {
            self.location.alert(rootFirebase.childByAppendingPath("cpr").childByAppendingPath(self.uid))
        }
    }
}