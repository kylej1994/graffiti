//
//  LoginViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var btnSignIn: GIDSignInButton!
    
    let labelText = "Please Sign in to Graffiti"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        setupGoogleSignIn()
    }
    
    func setupGoogleSignIn() {
        btnSignIn.center = view.center
        btnSignIn.style = GIDSignInButtonStyle.wide
    }
    
    func startLoading() {
        label?.text = "Loading..."
    }
    
    func stopLoading() {
        label?.text = labelText
    }
    
    // MARK: Alerts
    
    // call these functions to show alerts instead of labels
    // *but* for things like username too long, you should just stop letting user enter
    // text once the text is 100 characters...
    func showAlert(messageTitle: String, message: String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSignInErrorAlert() {
        showAlert(messageTitle: "Error Signing In", message: "There was a problem signing in with Google.")
    }
    
    func showLoginErrorAlert() {
        showAlert(messageTitle: "Error Connecting to Account", message: "ID Token from Google is missing.")
    }
    
    func showWhoopsAlert() {
        showAlert(messageTitle: "Whoops", message: "Couldn't connect to server to log in.")
    }

    
    // MARK: UITextFieldDelegate
    
    func navigateToTabs() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}


extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
