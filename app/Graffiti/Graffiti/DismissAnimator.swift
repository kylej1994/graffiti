//
//  DismissAnimator.swift
//  Graffiti
//
//  Created by Amanda Aizuss on 2/27/17.
//  Copyright © 2017 Amanda Aizuss. All rights reserved.
//

import Foundation
import UIKit

class DismissAnimator : NSObject {
    
}

extension DismissAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? ImageDetailViewController, // modal vc
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            return
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.imageDetailView.frame = finalFrame
            //fromVC.view.frame = finalFrame // for entire view to animate
        }, completion: {_ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}
