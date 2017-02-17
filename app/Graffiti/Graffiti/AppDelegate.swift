//
//  AppDelegate.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
//import Google
import GoogleSignIn

@UIApplicationMain
// [START appdelegate_interfaces]
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
   
    
    // [END appdelegate_interfaces]
    var window: UIWindow?
    var currentUser: User?
    
    
   
    
    
    
    // [START didfinishlaunching]
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    // [END didfinishlaunching]
    // [START openurl]
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    // [END openurl]
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    // [START signin_handler]
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        } else {
            
            // We have sucesfully signed in a User 
            
          //  currentUser = GIDSignIn.sharedInstance().currentUser
       
        
            // Perform any operations on signed in user here.
            
            API.sharedInstance.login() { res in
                // Handler
                // response.request
                // response.response
                //response.result -> enum either success or failure , 200-299 success otherwise failure
                //res.result.value -> actual value
                // let lvc = LoginViewControllor().
            let lvc = GIDSignIn.sharedInstance().uiDelegate as? LoginViewController
         //   print(res.result.value)
          //  print(res.result)
           // print(res.response)
           // print(res.request)
            switch res.result {
            case.success: lvc?.newuser(newuser: res.result.value as! Dictionary<String, Any>)
            case.failure: lvc?.showerrorlabel()

            }
            }
            
            
         //   let userId = user.userID                  // For client-side use only!
           // let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            // [START_EXCLUDE]
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in Google user:\(fullName!)"])
            // [END_EXCLUDE]
        }
    }
    // [END signin_handler]
    
    // [START disconnect_handler]
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
    // [END disconnect_handler]
}
