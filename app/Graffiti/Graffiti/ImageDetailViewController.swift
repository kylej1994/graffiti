//
//  ImageDetailViewController.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/27/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    var interactor: Interactor?  = nil
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
    
    @IBAction func handleDismissGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.4
        
        // convert y position to downward pull progress (percentage)
        let translation = sender.translation(in: view) // converts the pan gesture coordinate to the Modal View Controller’s coordinate space.
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
        
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
