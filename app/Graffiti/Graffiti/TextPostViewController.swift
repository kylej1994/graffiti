//
//  TextPostViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import CoreLocation

class TextPostViewController: UIViewController, UITextViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var charCount: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.postTextView.delegate = self
        // Do any additional setup after loading the view.
        
        postTextView.text = "What's new?"
        postTextView.textColor = UIColor .lightGray
        postTextView.layer.borderColor = UIColor.black.cgColor
        postTextView.layer.borderWidth = 1.0
        postTextView.layer.cornerRadius = 5.0
        
        // use the singleton instead
        let manager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        let numberOfChars = newText.characters.count
        
        if(numberOfChars > 140){
            charCount.textColor = UIColor.red
            charCount.text = String(140 - numberOfChars)
            postButton.isEnabled = false
        } else {
            charCount.textColor = UIColor.black
            charCount.text = String(140 - numberOfChars)
            postButton.isEnabled = true
        }
        
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postTextView.text = ""
        postTextView.textColor = UIColor .black
    
    }
    
    @IBAction func postGraffiti(_ sender: UIButton) {
        
        //let locationService = LocationService.sharedInstance
        //let lat = locationService.getLatitude()!
        //let long = locationService.getLongitude()!
        
        
        let lat:Double = 0.0
        let long:Double = 0.0
        let location = CLLocation.init(latitude: lat, longitude: long)
        
        let postText = postTextView.text!
        
        let newPost:Post = Post(location: location, text: postText)!
        
        API.sharedInstance.createPost(post: newPost){ response in
            if(response.result.isFailure){
                print(response.result.debugDescription)
            }
        }
        
        //print("We did it!")
        
    }
    
//    func showLongPostAlert() {
//        let alertController = UIAlertController(title: "Too long", message: <#T##String?#>, preferredStyle: <#T##UIAlertControllerStyle#>)
//    }
    
}
