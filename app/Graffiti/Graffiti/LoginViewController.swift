//
//  LoginViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    
    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var btnSignIn : GIDSignInButton!
    var label : UILabel!
    @IBOutlet var btnNewsFeed: UIButton!
    @IBOutlet weak var usertextnew: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        self.usertextnew.delegate = self
        
        showGoogleSignIn()
        usertextnew.isHidden = true
        btnNewsFeed.isHidden = true
        
        GIDSignIn.sharedInstance().signInSilently()
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
    
    func showUsernameTooLongAlert() {
        showAlert(messageTitle: "Username too long", message: "Your username must be under 100 characters.")
    }
    
    func showUsernameTakenAlert() {
        showAlert(messageTitle: "That username is taken", message: "Please enter a different username.")
    }
    
    // MARK: UITextFieldDelegate
    
    private func textViewDidBeginEditing(_ textView: UITextView) {
        usertextnew.text = ""
        usertextnew.textColor = UIColor .black
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let user = self.appDelegate.currentUser!
        
        // Hide the keyboard.
        usertextnew.resignFirstResponder()
        
        let username = usertextnew.text!
        print(username)
        
        do {
            try user.setUsername(username)
        } catch{
            showUsernameTooLongAlert()
            return false
        }
        
        API.sharedInstance.updateUser(user: user) { res in
            switch res.result{
            case.success:
                self.btnNewsFeed.isHidden = false
                // TODO: Navigate to Feed
            case.failure:
                self.showUsernameTakenAlert()
                self.usertextnew.becomeFirstResponder()
            }
        }
        return true
    }

    func handleNewUser(user: User) {
        print ("new user")
        
        usertextnew.isHidden = false
        btnSignIn.isHidden = true
        
        usertextnew.becomeFirstResponder()
    }
    
    // This function is called after a successful Google login
    func login() {
        API.sharedInstance.login() { res in
            switch res.result {
            case .success:
                if
                    let loginPayload = res.result.value as? [String : Any],
                    let newUser = loginPayload["new_user"] as? Bool,
                    let user = loginPayload["user"] as? User
                {
                    self.appDelegate.currentUser = user
                    if newUser {
                        self.handleNewUser(user: user)
                    } else {
                        // TODO: Navigate to Feed
                        self.btnNewsFeed.isHidden = false
                    }
                } else {
                    self.showLoginErrorAlert()
                }
            case .failure:
                self.showWhoopsAlert()
                self.showGoogleSignIn()
            }
        }
    }
    
  
    func toggleAuthUI() {
        
//        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
//            // Signed in
//            btnNewsFeed.isHidden = true
//            btnSignIn.isHidden = true
//            usertextnew.isHidden = true
//            
//            // Added to handle if user is already signed in 
//            if (GIDSignIn.sharedInstance().currentUser == nil) {
//                print("no user info")
//                GIDSignIn.sharedInstance().signInSilently()
//            }
//            
//        } else {
//            
//            // Not Signed In
//            btnNewsFeed.isHidden = true
//            btnSignIn.isHidden = false
//            usertextnew.isHidden = true
//        }
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
