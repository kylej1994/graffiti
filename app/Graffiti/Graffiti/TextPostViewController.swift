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
    let charLimit = 140
    let locationManager = LocationService.sharedInstance
    var currentLatitude: CLLocationDegrees? = CLLocationDegrees()
    var currentLongitude: CLLocationDegrees? = CLLocationDegrees()
    
    @IBOutlet weak var postTextView: UITextView!
    var barCharCountLabel: UILabel!
    var postButton: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        locationManager.startUpdatingLocation()
        postTextView.becomeFirstResponder() // show keyboard
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        locationManager.stopUpdatingLocation()
        postTextView.resignFirstResponder() // hide keyboard
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // handle text field's user input through delegate callbacks
        postTextView.delegate = self

        createCharCounterLabel()
        setupTextViewDisplay()
        addToolBarToKeyboard()
    }
    
    func createCharCounterLabel() {
        barCharCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 22))
        barCharCountLabel.textColor = UIColor.darkGray
        barCharCountLabel.text = "140"
    }
    
    func addToolBarToKeyboard() {
        let postToolbar = UIToolbar(frame: CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: 50))
        postToolbar.barStyle = .default
        postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postTextGraffiti(_:)))
        postButton.isEnabled = false // until user types
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) //for right aligned post button
        let charCountItem = UIBarButtonItem(customView: barCharCountLabel)
        postToolbar.items = [flexible, charCountItem, postButton]
        postToolbar.sizeToFit()
        postTextView.inputAccessoryView = postToolbar
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

        if(numberOfChars > charLimit){
            barCharCountLabel.textColor = UIColor.red
            barCharCountLabel.text = String(charLimit - numberOfChars)
            postButton.isEnabled = false
        } else if (numberOfChars == 0) {
            postButton.isEnabled = false
        } else {
            barCharCountLabel.textColor = UIColor.darkGray
            barCharCountLabel.text = String(charLimit - numberOfChars)
            postButton.isEnabled = true
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postTextView.text = ""
        postTextView.textColor = UIColor.black
        
    }
    
    
    func postTextGraffiti(_ sender: UIButton) {
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
        
        let newPost:Post = Post(location: location, text: postTextView.text!)!
        
        API.sharedInstance.createPost(post: newPost){ response in
            switch response.result {
            case.success:
                print("we sent a post with location \(location)")
            case .failure(let error):
                print(error)
            }
        }
        
        // return to presenting view controller
        postTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
}
