//
//  OnboardingViewController.swift
//  Graffiti
//
//  Created by Henry Lewis on 2/21/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation

class OnboardingViewController: UIViewController, UITextFieldDelegate {
    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        usernameTextField.text = ""
        usernameTextField.becomeFirstResponder()
        usernameTextField.autocorrectionType = .no
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameTextField.text = ""
        usernameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let user = self.appDelegate.currentUser!
        
        // Hide the keyboard.
        usernameTextField.resignFirstResponder()
        
        let username = usernameTextField.text!
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
                do {
                    try user.update(res.result.value)
                } catch {
                    self.showUpdateUserAlert()
                    self.usernameTextField.becomeFirstResponder()
                    return
                }
                self.navigateToTabs()
            case.failure:
                self.showUsernameTakenAlert()
                self.usernameTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func showAlert(messageTitle: String, message: String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showUsernameTooLongAlert() {
        showAlert(messageTitle: "Username too long", message: "Your username must be under 100 characters.")
    }
    
    func showUsernameTakenAlert() {
        showAlert(messageTitle: "That username is taken", message: "Please enter a different username.")
    }
    
    func showUpdateUserAlert() {
        showAlert(messageTitle: "Update Profile Error", message: "There was a problem updating your profile.  Pleasure try again.")
    }
    
    func navigateToTabs() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}
