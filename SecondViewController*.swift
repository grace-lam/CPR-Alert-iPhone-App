//
//  SecondViewController.swift
//  CPR Alert
//
//  Created by Grace Lam on 8/14/14.
//  Copyright (c) 2014 Grace Lam. All rights reserved.
//

import UIKit
import CoreLocation

var model:CPRModel = CPRModel()

class SecondViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var settingsLabel:UILabel!
    @IBOutlet var certifiedSwitch:UISwitch!
    @IBOutlet var notificationButton:UIButton!
    @IBOutlet var locationButton:UIButton!
    @IBOutlet var alertDistanceControl:UISegmentedControl!
    @IBOutlet var logoutButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.viewControllers?.first?.viewDidLoad()
        
        model.accountView = self
        
        if (model.user != nil) {
            model.user.updateAccount()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            if (model.user != nil) {
                model.user.updateAccount()
            }
        }
    }
    
    @IBAction func cprStateChange(sender:UISwitch) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Your change may not be saved. Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            model.user.setCPRState(sender.on)
        }
    }
    
    @IBAction func maxDistance(sender:UISegmentedControl) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Your change may not be saved. Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            model.user.setMaxDistance(sender.selectedSegmentIndex)
        }
    }
    
    @IBAction func notificationState(sender:UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
    }
    
    @IBAction func locationState(sender:UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
    }
    
    @IBAction func logout(sender:UIButton) {
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            Firebase(url:"***").unauth()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

