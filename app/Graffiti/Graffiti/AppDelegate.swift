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
    var loginViewController: LoginViewController!
    
    // MARK: App Properties
    var currentUser: User?
    
    
    // Finished Launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Init LoginViewController
        loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        // If previously logged in
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            navigateToLogin()
        }
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
            navigateToLogin()
            loginViewController.showSignInErrorAlert()
        } else {
            // Successful Sign in
            self.login(googleUser: user)
        }
    }
    
    // Disconnect Handler
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        navigateToLogin()
    }
    
    // This function is called after a successful Google login
    func login(googleUser: GIDGoogleUser) {
        API.sharedInstance.login() { res in
            switch res.result {
            case .success:
                if
                    let loginPayload = res.result.value as? [String : Any],
                    let newUser = loginPayload["new_user"] as? Bool,
                    let user = loginPayload["user"] as? User
                {
                    self.currentUser = user
                    if newUser {
                        user.setEmail(googleUser.profile.email)
                        user.setName(googleUser.profile.name)
                        self.navigateToLogin()
                        self.loginViewController.handleNewUser(user: user)
                    } else {
                        self.loginViewController.navigateToTabs()
                    }
                } else {
                    self.navigateToLogin()
                    self.loginViewController.showLoginErrorAlert()
                }
            case .failure:
                self.navigateToLogin()
                self.loginViewController.showWhoopsAlert()
                self.loginViewController.showGoogleSignIn()
            }
        }
    }
    
    func navigateToLogin() {
        self.window?.rootViewController = loginViewController
        self.window?.makeKeyAndVisible()
    }
}
