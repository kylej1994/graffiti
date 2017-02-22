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
    let locationManager = LocationService.sharedInstance
    var currentLatitude: CLLocationDegrees? = CLLocationDegrees()
    var currentLongitude: CLLocationDegrees? = CLLocationDegrees()
    var postText: String = String()
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
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
        postTextView.delegate = self
        setupTextViewDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTextViewDisplay() {
        postTextView.text = "What's happening?"
        postTextView.textColor = UIColor .lightGray
        postTextView.layer.borderColor = UIColor.black.cgColor
        postTextView.layer.borderWidth = 1.0
        postTextView.layer.cornerRadius = 5.0
    }
    // MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        
        if(numberOfChars > 140){
            charCountLabel.textColor = UIColor.red
            charCountLabel.text = String(140 - numberOfChars)
            postButton.isEnabled = false
        } else if (numberOfChars == 0) {
            postButton.isEnabled = false
        } else {
            charCountLabel.textColor = UIColor.black
            charCountLabel.text = String(140 - numberOfChars)
            postButton.isEnabled = true
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postTextView.text = ""
        postTextView.textColor = UIColor.black
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        postText = postTextView.text!
    }
    
    // should i show and hide the keyboard somewhere?
    
    
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
