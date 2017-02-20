//
//  AppDelegate.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    
    // MARK: App Properties
    var currentUser: User?
    
    
    // Finished Launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        return true
    }

    // Open Url
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let souceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: souceApplication, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    // Sign In Handler
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            // Silent
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
        } else {
            // Successful Sign in
            API.sharedInstance.login() { res in
                let lvc = GIDSignIn.sharedInstance().uiDelegate as? LoginViewController
                switch res.result {
                case .success:
                    lvc?.newuser(newuser: res.result.value as! Dictionary<String, Any>)
                case .failure:
                    lvc?.showWhopsAlert()
                    lvc?.showGoogleSignIn()
                }
            }
            
            let fullName = user.profile.name
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in Google user:\(fullName!)"])
        }
    }
    
    // Disconnect Handler
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
    }
}
