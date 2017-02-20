//
//  LoginViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    
    //var btnSignIn : UIButton!
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

        // Sign In Label
        label = UILabel(frame: CGRect(0,0,200,100))
        label.center = CGPoint(view.center.x, 300)
        label.numberOfLines = 0 //Multi-lines
        label.text = "Please Sign in to Graffiti Using Google"
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
    
        NotificationCenter.default.addObserver(self, selector: #selector(receiveToggleAuthUINotification(_:)),
        name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),object: nil)
        
        toggleAuthUI()
    }
    
    // call these functions to show alerts instead of labels
    // *but* for things like username too long, you should just stop letting user enter
    // text once the text is 100 characters...
    func showAlert(messageTitle: String, message: String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoginErrorAlert() {
        showAlert(messageTitle: "Error Connecting to Account", message: "ID Token from Google is missing")
    }
    
    func showWhoopsAlert() {
        showAlert(messageTitle: "Whoops", message: "Couldn't connect to server to log in")
    }
    
    func showUsernameTooLongAlert() {
        showAlert(messageTitle: "Username too long", message: "Your username must be under 100 characters")
    }
    
    func showUsernameTakenAlert() {
        showAlert(messageTitle: "That username is taken", message: "Please enter a different username")
    }
    
    func showGoogleSignIn() {
        btnSignIn = GIDSignInButton(frame: CGRect(0,0,230,48))
        btnSignIn.center = view.center
        btnSignIn.style = GIDSignInButtonStyle.wide
        view.addSubview(btnSignIn)
    }
    
    private func textViewDidBeginEditing(_ textView: UITextView) {
        usertextnew.text = ""
        usertextnew.textColor = UIColor .black
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        usertextnew.resignFirstResponder()
        return true
    }

    func newuser(newuser: [String : Any]) {
        let nu = newuser["new_user"]
        if (nu as? Bool == false) {
            print("current user already there")
            usertextnew.isHidden = true
            self.btnNewsFeed.isHidden = false
        } else {
            print ("new user")
            self.btnNewsFeed.isHidden = true
            let user = newuser["user"] as! User
            
            // setting current user
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.currentUser = user
            usertextnew.isHidden = false
            usertextnew.becomeFirstResponder()
            let username = usertextnew.text!
            print(username)
            do {
                try user.setUsername(username)
            } catch{
                showUsernameTooLongAlert()
            }
            API.sharedInstance.updateUser(user: user) { res in
                switch res.result{
                case.success:
                    self.btnNewsFeed.isHidden = false
                case.failure:
                    self.showUsernameTakenAlert()
                }
            }
        }
    }
    
  
    func toggleAuthUI() {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            // Signed in
            btnNewsFeed.isHidden = true
            btnSignIn.isHidden = true
            usertextnew.isHidden = true
            
            // Added to handle if user is already signed in 
            if (GIDSignIn.sharedInstance().currentUser == nil) {
                print("no user info")
                GIDSignIn.sharedInstance().signInSilently()
            }
            
        } else {
            
            // Not Signed In
            btnNewsFeed.isHidden = true
            btnSignIn.isHidden = false
            usertextnew.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if (notification.name == NSNotification.Name(rawValue: "ToggleAuthUINotification")) {
            self.toggleAuthUI()
            if notification.userInfo != nil {
                let userInfo:Dictionary<String,String?> =
                    notification.userInfo as! Dictionary<String,String?>
                self.label.text = userInfo["statusText"]!
            }
        }
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
