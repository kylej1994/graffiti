//
//  LoginViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    
    var btnSignIn : UIButton!
    var label : UILabel!
    var welcome : UILabel!
    var loginerror : UILabel!
    var untoolong : UILabel!
    var logo : UIImageView!
    @IBOutlet var btnNewsFeed: UIButton!
    @IBOutlet weak var usertextnew: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         self.view.backgroundColor = UIColor.black
        
        GIDSignIn.sharedInstance().uiDelegate = self
        self.usertextnew.delegate = self
    
        
        
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

        
        welcome = UILabel(frame: CGRect(100,300,600,100))
        welcome.text = "Welcome to Grafitti"
        welcome.font = welcome.font.withSize(40)
        welcome.center = CGPoint(view.center.x, 50)
        welcome.textColor = UIColor.cyan
        welcome.textAlignment = NSTextAlignment.center
        view.addSubview(welcome)
        
        loginerror = UILabel(frame: CGRect(0,0,200,100))
        loginerror.text = "There Was an Error Connectting to Account, Idtoken from Google is Missing"
        loginerror.numberOfLines = 4 //Multi-lines
        loginerror.font = loginerror.font.withSize(10)
        loginerror.center = CGPoint(view.center.x, 250)
        loginerror.textColor = UIColor.red
        loginerror.textAlignment = NSTextAlignment.center
        view.addSubview(loginerror)
        
        untoolong = UILabel(frame: CGRect(0,0,200,100))
        untoolong.text = "The Username you have entered is too long. It must be under 100 characters"
        untoolong.numberOfLines = 4 //Multi-lines
        untoolong.font = loginerror.font.withSize(10)
        untoolong.center = CGPoint(view.center.x, 400)
        untoolong.textColor = UIColor.red
        untoolong.textAlignment = NSTextAlignment.center
        view.addSubview(untoolong)
        
        loginerror.isHidden = true
        usertextnew.isHidden = true
        untoolong.isHidden = true
        
        
        
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
    
    
    
    private func textViewDidBeginEditing(_ textView: UITextView) {
        usertextnew.text = ""
        usertextnew.textColor = UIColor .black
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        usertextnew.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show keyboard by default
        super.viewDidLoad()
        usertextnew.becomeFirstResponder()
    }

    

    func btnSignInPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    

    func newuser(newuser: Dictionary<String, Any>) {
        let nu = newuser["new_user"]
        if (nu as? Bool == false) {
            print("current user already there")
        usertextnew.isHidden = true
         self.welcome.isHidden = true
          self.btnNewsFeed.isHidden = false
            
            
        }
        else {
        print ("new user")
        self.btnNewsFeed.isHidden = true
        self.welcome.isHidden = false
        untoolong.text = "You Must Enter a Username"
        untoolong.isHidden = false
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
                untoolong.isHidden = false
                
            }
            API.sharedInstance.updateUser(user: user) { res in
                
                switch res.result{
                case.success:
                    self.usertextnew.isHidden = true
                    self.untoolong.isHidden = true
                    self.welcome.isHidden = true
                    self.btnNewsFeed.isHidden = false
                    print("why")
                    
                case.failure:
                    self.untoolong.text = "Please Re-enter a new Username. That Username is already taken"
                    self.untoolong.isHidden = false
                }
            }
            
    }
        
    
    }
    
    func showerrorlabel(){
        loginerror.isHidden = false
    }
    
    
  
    
    func toggleAuthUI() {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            // Signed in
            welcome.isHidden = true
            btnNewsFeed.isHidden = true
            btnSignIn.isHidden = true
            loginerror.isHidden = true
            usertextnew.isHidden = true
            untoolong.isHidden = true
            
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
            loginerror.isHidden = true
            usertextnew.isHidden = true
            untoolong.isHidden = true
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
