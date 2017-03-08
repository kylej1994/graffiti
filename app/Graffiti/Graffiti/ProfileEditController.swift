//
//  ProfileEditController.swift
//  Graffiti
//
//  Created by techbar on 2/26/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit
import Foundation

class EditProfileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioEditor: UITextView!
    @IBOutlet weak var profPicButton: UIButton!
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollContainer: UIScrollView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var barCharCountLabel: UILabel!
    
    
    let charLimit = 140
    
    var user: User? = nil
    var bio: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bioEditor.delegate = self // amanda added this
        createCharCounterLabel()
        addToolBarToKeyboard()
        
        if let user = appDelegate.currentUser {
            print("app delegate current user can be unwrapped")
            self.user = user
        } else {
            print("sadness")
        }
        
        bioEditor.delegate = self
        
        // profPicButton.layer.cornerRadius = 0.5 * profPicButton.bounds.size.width
        // profPicButton.clipsToBounds = true
        
        usernameLabel.text = user?.getUsername()
        bio = user?.getBio()
        if(bio != nil){
            bioEditor.text = bio
        } else {
            bioEditor.text = "Enter a bio!"
        }
        barCharCountLabel.text = String(charLimit - bioEditor.text.characters.count)
        if let userPhoto = user?.getImageTag() {
            profPicButton.setImage(userPhoto, for: .normal)
        } else {
            profPicButton.setImage(#imageLiteral(resourceName: "cat-prof-100"), for: .normal)
        }
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        saveNewBio(text: bio)
        dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        
        // hide keyboard when done
        if(text == "\n") {
            textView.resignFirstResponder()
            bio = bioEditor.text
            print("dismissing keyboard: \(bio)")
            return false
        }
        
        if(numberOfChars > charLimit){
            barCharCountLabel.textColor = UIColor.red
            barCharCountLabel.text = String(charLimit - numberOfChars)
            saveButton.isEnabled = false
        } else {
            bio = bioEditor.text
            barCharCountLabel.textColor = UIColor.darkGray
            barCharCountLabel.text = String(charLimit - numberOfChars)
            saveButton.isEnabled = true
        }
        return true
    }
    
    func saveNewBio(text: String) {
        let user = self.user!
        print("saving: \(bio)")
        do {
            try user.setBio(bio)
        } catch {
            print("unable to set bio!")
            return
        }
        
        API.sharedInstance.updateUser(user: user) { res in
            switch res.result{
            case.success:
                do {
                    try self.user?.update(res.result.value)
                } catch {
                    self.showUpdateUserAlert()
                    self.bioEditor.becomeFirstResponder()
                    return
                }
            case.failure:
                self.showUpdateUserAlert()
                self.bioEditor.becomeFirstResponder()
            }
        }
        return
    }
    
    @IBAction func tapProfilePhotoButton(_ sender: UIButton) {
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photo button to display the selected image.
        profPicButton.setImage(selectedImage, for: .normal)
        
        let user = self.user!
        user.setTagImage(selectedImage)
        
        if(user.getImageTag() != nil){
            print("the image was updated")
        }
        
        API.sharedInstance.updateUser(user: user) { res in
            switch res.result{
            case.success:
                do {
                    try self.user?.update(res.result.value)
                    print("updated the profile photo!")
                } catch {
                    self.showUpdateUserAlert()
                    return
                }
            case.failure:
                self.showUpdateUserAlert()
            }
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)

    }
    
    func showAlert(messageTitle: String, message: String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showUpdateUserAlert() {
        showAlert(messageTitle: "Update Profile Error", message: "There was a problem updating your profile.  Pleasure try again.")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        bioEditor.text = user?.getBio()
        bioEditor.textColor = UIColor.black
        scrollContainer.setContentOffset(CGPoint(0, 50), animated: true)
        
    }
    
    func createCharCounterLabel() {
        barCharCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 22))
        barCharCountLabel.textColor = UIColor.darkGray
        barCharCountLabel.text = "140"
    }
    
    func addToolBarToKeyboard() {
        let postToolbar = UIToolbar(frame: CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: 50))
        postToolbar.barStyle = .default
        // flexible space necessary for right alignment
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let charCountItem = UIBarButtonItem(customView: barCharCountLabel)
        postToolbar.items = [flexible, charCountItem]
        postToolbar.sizeToFit()
        bioEditor.inputAccessoryView = postToolbar
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        scrollContainer.setContentOffset(CGPoint(0, -50), animated: true)
    }
}
