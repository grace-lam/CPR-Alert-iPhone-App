//
//  AppDelegate.swift
//  CPR Alert v1.0
//
//  Created by Grace Lam on 8/14/14.
//  Copyright (c) 2014 Grace Lam. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager:CLLocationManager = CLLocationManager()
    
    var accountView:SecondViewController!
    
    func application(application: UIApplication, openURL url: NSURL,
        sourceApplication: String?, annotation: AnyObject?) -> Bool {
            return GPPURLHandler.handleURL(url,
                sourceApplication:sourceApplication,
                annotation:annotation)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // grab correct storyboard depending on screen height
        let storyboard:UIStoryboard = self.grabStoryboard()
        
        // display storyboard
        self.window?.rootViewController = (storyboard.instantiateInitialViewController() as! UIViewController)
        self.window?.makeKeyAndVisible()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        UITabBar.appearance().tintColor = UIColor( red: 228/255.0, green: 47/255.0, blue: 62/255.0, alpha: 1 )
        
        return true
    }
    
    
    func grabStoryboard() -> UIStoryboard {
        // determine screen size
        let screenHeight:CGFloat = UIScreen.mainScreen().bounds.size.height
        let storyboard:UIStoryboard!
        
        switch (screenHeight) {
            // iPhone 4s
            case 480:
                storyboard = UIStoryboard(name: "Main-4", bundle: nil)
                break
            
            default:
                storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        return storyboard
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        model.tokenData = deviceToken.description
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        
        model.firstTimeViewingAlert = true
        
        handler(UIBackgroundFetchResult.NoData)
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (model.user != nil && model.user.uid != nil) {
            if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
                model.user.locState = true
                
            } else if (status == CLAuthorizationStatus.Denied) {
                model.user.locState = false
            }
        }
    }
    
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        // stop updating location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // stop updating location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // stop updating location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
            locationManager.stopUpdatingLocation()
        }
    }
}

