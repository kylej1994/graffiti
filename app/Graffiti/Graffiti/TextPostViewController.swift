//
//  TextPostViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/6/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class TextPostViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var charCount: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.postTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextField) {
        
        let textViewFixedWidth: CGFloat = self.postTextField.frame.size.width
        let newSize: CGSize = self.postTextField.sizeThatFits(CGSize(textViewFixedWidth, CGFloat(MAXFLOAT)))
        var newFrame: CGRect = self.postTextField.frame
        
        //var textViewYPosition = self.postTextField.frame.origin.y
        let heightDifference = self.postTextField.frame.height - newSize.height
        
        if (abs(heightDifference) > 20) {
            newFrame.size = CGSize(fmax(newSize.width, textViewFixedWidth), newSize.height)
            newFrame.offsetBy(dx: 0.0, dy: 0)
        }
        self.postTextField.frame = newFrame
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        
        //change the value of the label
        charCount.text =  String(newLength)
        
        //return true to allow the change, if you want to limit the number of characters in the text field use something like
        return newLength <= 140
    }
    
}
