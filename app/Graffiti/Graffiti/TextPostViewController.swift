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
        postTextView.layer.borderColor = UIColor.blue.cgColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let textViewFixedWidth: CGFloat = self.postTextView.frame.size.width
        let newSize: CGSize = self.postTextView.sizeThatFits(CGSize(textViewFixedWidth, CGFloat(MAXFLOAT)))
        var newFrame: CGRect = self.postTextView.frame
        
        //var textViewYPosition = self.postTextView.frame.origin.y
        let heightDifference = self.postTextView.frame.height - newSize.height
        
        if (abs(heightDifference) > 20) {
            newFrame.size = CGSize(fmax(newSize.width, textViewFixedWidth), newSize.height)
            newFrame.offsetBy(dx: 0.0, dy: 0)
        }
        self.postTextView.frame = newFrame
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        let numberOfChars = newText.characters.count
        
        //charCount.text = String(140 - numberOfChars)
        
        if(numberOfChars > 140){
            charCount.textColor = UIColor.red
            charCount.text = String(140 - numberOfChars)
        } else {
            charCount.textColor = UIColor.black
            charCount.text = String(140 - numberOfChars)
        }
        
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postTextView.text = ""
        postTextView.textColor = UIColor .black
    
    }
    
    @IBAction func postButton(_ sender: UIButton){
        
        let locationService = LocationService.sharedInstance
        let lat = locationService.getLatitude()
        let long = locationService.getLongitude()
        let location = CLLocation.init(latitude: lat!, longitude: long!)
        
        let postText = postTextView.text!
        
        //let newPost:Post = Post(text: postText, location: location)!
        
        //API.sharedInstance.createPost(post: newPost , handler: <#T##Handler##Handler##(DataResponse<Any>) -> Void#>)
    }
    
}
