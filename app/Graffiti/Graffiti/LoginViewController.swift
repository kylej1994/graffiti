//
//  LoginViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    var btnSignIn : UIButton!
    var btnSignOut : UIButton!
    var btnDisconnect : UIButton!
    var label : UILabel!
    var welcome : UILabel!
    var logo : UIImageView!
    @IBOutlet var btnNewsFeed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         self.view.backgroundColor = UIColor.black
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        logo = UIImageView(frame: CGRect(0, 0, 150, 150))
        logo.center = CGPoint(view.center.x, 150)
        logo.image = UIImage(named:"Logo")
        view.addSubview(logo)
        
        let btnSize : CGFloat = 100
        btnSignIn = UIButton(frame: CGRect(0,0,btnSize,btnSize))
        btnSignIn.center = view.center
        btnSignIn.setImage(UIImage(named: "GoogleLogo"), for: UIControlState.normal)
        btnSignIn.addTarget(self, action: #selector(btnSignInPressed(_:)), for: UIControlEvents.touchUpInside)
        
        //Circular button
        btnSignIn.layer.cornerRadius = btnSize/8
        btnSignIn.layer.masksToBounds = true
        btnSignIn.layer.borderColor = UIColor.black.cgColor
        btnSignIn.layer.borderWidth = 2
        view.addSubview(btnSignIn)

        
        btnSignOut = UIButton(frame: CGRect(0,0,100,30))
        btnSignOut.center = CGPoint(view.center.x, 100)
        btnSignOut.setTitle("Sign Out", for: UIControlState.normal)
        btnSignOut.setTitleColor(UIColor.blue, for: UIControlState.normal)
        btnSignOut.setTitleColor(UIColor.cyan, for: UIControlState.highlighted)
        btnSignOut.addTarget(self, action: #selector(btnSignOutPressed(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(btnSignOut)
        
       
        
        btnDisconnect = UIButton(frame: CGRect(0,0,100,30))
        btnDisconnect.center = CGPoint(view.center.x, 200)
        btnDisconnect.setTitle("Disconnect", for: UIControlState.normal)
        btnDisconnect.setTitleColor(UIColor.blue, for: UIControlState.normal)
        btnDisconnect.setTitleColor(UIColor.cyan, for: UIControlState.highlighted)
        btnDisconnect.addTarget(self, action: #selector(btnDisconnectPressed(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(btnDisconnect)
        
        welcome = UILabel(frame: CGRect(100,300,600,100))
        welcome.text = "Welcome to Grafitti"
        welcome.font = welcome.font.withSize(40)
        welcome.center = CGPoint(view.center.x, 50)
        welcome.textColor = UIColor.cyan
        welcome.textAlignment = NSTextAlignment.center
        view.addSubview(welcome)
        
        
        
        label = UILabel(frame: CGRect(0,0,200,100))
        label.center = CGPoint(view.center.x, 300)
        label.numberOfLines = 0 //Multi-lines
        label.text = "Please Sign in to Graffiti Using Google"
        label.textColor = UIColor.cyan
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveToggleAuthUINotification(_:)),
        name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),object: nil)
        
        toggleAuthUI()
        
    }
    
    func btnSignInPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    func btnDisconnectPressed(_ sender: UIButton) {
        label.text = "Signed out."
        toggleAuthUI()
    }
    
    func btnSignOutPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().disconnect()
        label.text = "Disconnecting."
    }
    
   
    
  
    
    func toggleAuthUI() {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            // Signed in
            welcome.isHidden = true
            btnNewsFeed.isHidden = false
            btnSignIn.isHidden = true
            btnSignOut.isHidden = false
            btnDisconnect.isHidden = true
            
            
            // Added to handle if user is already signed in 
            if (GIDSignIn.sharedInstance().currentUser == nil) {
                print("no user info")
                GIDSignIn.sharedInstance().signInSilently()
            }
            
        } else {
            
            // Not Signed In
            welcome.isHidden = false
            btnNewsFeed.isHidden = true
            btnSignIn.isHidden = false
            btnSignOut.isHidden = true
            btnDisconnect.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                            object: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
