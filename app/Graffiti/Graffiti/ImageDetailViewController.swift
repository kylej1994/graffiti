//
//  ImageDetailViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/27/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    @IBOutlet var imageDetailView: UIImageView!
    var originalImageViewCenter: CGPoint!
    var imageMoveOffset: CGFloat!
    var imageUp: CGPoint!
    var imageDown: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanImage(sender:)))
        imageDetailView.addGestureRecognizer(panGesture)
        
        imageMoveOffset = self.view.frame.height // how much the image moves up or down
        imageUp = CGPoint(x: imageDetailView.center.x ,y: imageDetailView.center.y - imageMoveOffset)
        imageDown = CGPoint(x: imageDetailView.center.x ,y: imageDetailView.center.y + imageMoveOffset)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func didPanImage(sender: UIPanGestureRecognizer) {
        //let location = sender.location(in: view)
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            originalImageViewCenter = sender.view?.center
        } else if sender.state == .changed {
            sender.view?.center = CGPoint(x: originalImageViewCenter.x, y: originalImageViewCenter.y + translation.y)
        } else if sender.state == .ended {
            if velocity.y > imageDetailView.frame.height/3 {
                UIView.animate(withDuration: 0.3) {
                    self.imageDetailView.center = self.imageDown
                    self.dismiss(animated: true, completion: nil)
                }
            } else if velocity.y < (0 - imageDetailView.frame.height)/3 {
                UIView.animate(withDuration: 0.3) {
                    self.imageDetailView.center = self.imageUp
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.imageDetailView.center = self.originalImageViewCenter
                }
            }
        }
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
