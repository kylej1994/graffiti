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
    var btnSignIn : GIDSignInButton!
    var label : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        showGoogleSignIn()
    }
    
    func showGoogleSignIn() {
        // Sign In Label
        // TODO: move this to the storyboard
        label = UILabel(frame: CGRect(0,0,200,100))
        label.center = CGPoint(view.center.x, 300)
        label.numberOfLines = 0 //Multi-lines
        label.text = "Please Sign in to Graffiti Using Google"
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        
        
        btnSignIn = GIDSignInButton(frame: CGRect(0,0,230,48))
        btnSignIn.center = view.center
        btnSignIn.style = GIDSignInButtonStyle.wide
        view.addSubview(btnSignIn)
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
