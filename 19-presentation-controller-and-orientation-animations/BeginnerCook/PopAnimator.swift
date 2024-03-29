//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by Rana Sohaib on 14.02.24.
//  Copyright © 2024 Razeware LLC. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  let duration = 1.0
  var presenting = true
  var originFrame = CGRect.zero
  
  var dismissCompletion: (() -> Void)?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    print("Presenting/Dismissing Scenario: Called 2nd")
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    print("Presenting/Dismissing Scenario: Called 3rd")
    let containerView = transitionContext.containerView
    let herbView = presenting ? transitionContext.view(forKey: .to) : transitionContext.view(forKey: .from)
    
    let herbViewController = presenting ? transitionContext.viewController(forKey: .to) :
                                          transitionContext.viewController(forKey: .from)
    
    guard let herbView = herbView, let herbViewController = herbViewController as? HerbDetailsViewController else {
      transitionContext.completeTransition(false)
      return
    }
    
    let initialFrame = presenting ? originFrame : herbView.frame
    let finalFrame = presenting ? herbView.frame : originFrame
    
    let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
    
    let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
    
    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
    
    // Setting initial position
    if presenting {
      herbView.transform = scaleTransform
      herbView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
      herbView.clipsToBounds = true
      herbView.layer.cornerRadius = 20.0 / xScaleFactor
      herbViewController.containerView.alpha = 0.0
    }
    
    if let toView = transitionContext.view(forKey: .to) {
      containerView.addSubview(toView)
    }
    containerView.bringSubviewToFront(herbView)
    
    // Animating to the final position
    UIView.animate(withDuration: duration,
                   delay:0.0,
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 0.0,
                   animations: {
      
      herbView.transform = self.presenting ?
      CGAffineTransform.identity : scaleTransform
      herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
      herbView.layer.cornerRadius = self.presenting ? 0.0 : 20 / xScaleFactor
      herbViewController.containerView.alpha = self.presenting ? 1.0 : 0.0
      
    }, completion: { _ in
      if !self.presenting { self.dismissCompletion?() }
      transitionContext.completeTransition(true)
    })
  }
}
