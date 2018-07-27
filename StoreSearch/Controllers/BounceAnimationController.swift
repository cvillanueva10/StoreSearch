//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Christopher Villanueva on 7/27/18.
//  Copyright © 2018 Christopher Villanueva. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to) {
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                    delay: 0,
                                    options: .calculationModeCubic,
                                    animations: {
                                        toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                        UIView.addKeyframe(withRelativeStartTime: 0.334,
                                                           relativeDuration: 0.333) {
                                                            toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                        }
                                        UIView.addKeyframe(withRelativeStartTime: 0.667,
                                                           relativeDuration: 0.333) {
                                                            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                        }
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
