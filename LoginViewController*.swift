//
//  LoginViewController.swift
//  CPR Alert
//
//  Created by Grace Lam on 2/21/15.
//  Copyright (c) 2015 Grace Lam. All rights reserved.
//

import Foundation


class LoginViewController:UIViewController, UITextFieldDelegate {
    var cpr:Firebase = Firebase(url:"***")
    
    @IBOutlet var email:UITextField!
    @IBOutlet var password:UITextField!
    var retryGoogleLogin:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate = self
        password.delegate = self
        password.secureTextEntry = true
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func loginWithEmail(sender:UIButton) {
        
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        cpr.authUser(email.text, password: password.text) {
            error, authData in
            if error != nil {
                
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "The email or password is incorrect. Please try again."
                alert.addButtonWithTitle("OK")
                alert.show()
            } else {
                
                model.login(authData.uid)
                self.performSegueWithIdentifier("login", sender: self)
            }
        }
    }
    
    @IBAction func signUpWithEmail(sender:UIButton) {
        
        if Reachability.isConnectedToNetwork() == false {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        if email.text == "" || password.text == "" {
            let alert = UIAlertView()
            alert.title = "Create an Account"
            alert.message = "Please enter an email address and password. Then, tap Sign Up."
            alert.addButtonWithTitle("OK")
            alert.show()
        } else {
        
        cpr.createUser(email.text, password: password.text,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = "Invalid email address. Please try again."
                    alert.addButtonWithTitle("OK")
                    alert.show()
                } else {
                    self.cpr.authUser(self.email.text, password: self.password.text) {
                        error, authData in
                        if error != nil {
                            
                        } else {
                            
                            model.login(authData.uid)
                            self.performSegueWithIdentifier("login", sender: self)
                        }
                    }
                }
        })
            
        }
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    @IBAction func googleLogin(sender:UIButton) {
//        
//        if Reachability.isConnectedToNetwork() == false {
//            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//        }
//        
//        retryGoogleLogin = true
//        authenticateWithGoogle()
//    }
//    
//    func authenticateWithGoogle() {
//        // use the Google+ SDK to get an OAuth token
//        var signIn = GPPSignIn.sharedInstance()
//        signIn.shouldFetchGooglePlusUser = true
//        signIn.clientID = "***"
//        signIn.scopes = ["email"]
//        signIn.delegate = self
//        signIn.authenticate()
//    }
//    
//    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
//        if error != nil {
//            //println("google oauth error")
//            if (retryGoogleLogin == true) {
//                retryGoogleLogin = false
//                authenticateWithGoogle()
//            }
//            // There was an error obtaining the Google+ OAuth Token
//        } else {
//            //println("google oauth success")
//            // Successfully obtained an OAuth token, authenticate on Firebase with it
//            let ref = Firebase(url: "***")
//            ref.authWithOAuthProvider("google", token: auth.accessToken,
//                withCompletionBlock: { error, authData in
//                    if error != nil {
//                        //println("firebase oauth error")
//                        // Error authenticating with Firebase with OAuth token
//                    } else {
//                        // User is now logged in!
//                        //println("logged in")
//                        
//                        let defaults = NSUserDefaults.standardUserDefaults()
//                        defaults.setObject(auth.accessToken, forKey: "googleauth")
//                        
//                        model.login(authData.uid)
//                        
//                        self.performSegueWithIdentifier("login", sender: self)
//                    }
//            })
//        }
//    }
}