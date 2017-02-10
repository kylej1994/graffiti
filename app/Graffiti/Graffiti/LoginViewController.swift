//
//  LoginViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    var btnSignIn : GIDSignInButton!
    var btnSignOut : UIButton!
    var btnDisconnect : UIButton!
    var label : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        btnSignIn = GIDSignInButton(frame: CGRect(0,0,230,48))
        btnSignIn.center = view.center
        btnSignIn.style = GIDSignInButtonStyle.wide
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
        
        
        label = UILabel(frame: CGRect(0,0,200,100))
        label.center = CGPoint(view.center.x, 400)
        label.numberOfLines = 0 //Multi-lines
        label.text = "Please Sign in."
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveToggleAuthUINotification(_:)),
        name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),object: nil)
        
        toggleAuthUI()
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
            btnSignIn.isHidden = true
            btnSignOut.isHidden = false
            btnDisconnect.isHidden = true
        } else {
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
