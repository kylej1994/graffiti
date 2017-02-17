//
//  ProfileViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var btnSignOut : UIButton!
    var btnDisconnect : UIButton!
    var label : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignOut = UIButton(frame: CGRect(0,0,100,30))
        btnSignOut.center = CGPoint(view.center.x, 500)
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
        label.center = CGPoint(view.center.x, 300)
        label.numberOfLines = 0 //Multi-lines
        label.text = "Please Sign in to Graffiti Using Google"
        label.textColor = UIColor.cyan
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        
        label.isHidden = true
        btnDisconnect.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    func btnDisconnectPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextviewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(nextviewController, animated: true, completion: nil)
        
        
        label.text = "Signed out."
        label.isHidden = false
        LoginViewController().toggleAuthUI()
        
        
       
        
    }
    
    func btnSignOutPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().disconnect()
        label.text = "Disconnecting."
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
