//
//  TextPostViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import CoreLocation

class TextPostViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    let locationManager = LocationService.sharedInstance
    var currentLatitude: CLLocationDegrees? = CLLocationDegrees()
    var currentLongitude: CLLocationDegrees? = CLLocationDegrees()
    var postText: String = String()
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var charCountLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // handle text field's user input through delegate callbacks
        postTextField.delegate = self
        
        postTextField.layer.cornerRadius = 5.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        postTextField.textColor = UIColor.black
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let numChars = textField.text!.characters.count +  (textField.text!.characters.count - range.length)
        if numChars > 140 {
            charCountLabel.textColor = UIColor.red
            charCountLabel.text = String(140 - numChars)
            postButton.isEnabled = false
        } else if numChars == 0 {
            postButton.isEnabled = false
        } else {
            charCountLabel.textColor = UIColor.gray
            charCountLabel.text = String(140 - numChars)
            postButton.isEnabled = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        postText = postTextField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func postTextGraffiti(_ sender: UIButton) {
        currentLongitude = locationManager.getLongitude()
        currentLatitude = locationManager.getLatitude()
        if currentLongitude == nil {
            print("long was nil so setting to 0")
            currentLongitude = 0.0
        }
        if currentLatitude == nil {
            print("lat was nil so setting to 0")
            currentLatitude = 0.0
        }
        
        let location = CLLocation.init(latitude: currentLatitude!, longitude: currentLongitude!)
        
        let newPost:Post = Post(location: location, text: postText)!
        
        API.sharedInstance.createPost(post: newPost){ response in
            switch response.result {
            case.success:
                print("we sent a post with location \(location)")
            case .failure(let error):
                print(error)
            }
        }
        
        // return to presenting view controller
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
