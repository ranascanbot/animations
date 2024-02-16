//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by Rana Sohaib on 15.02.24.
//  Copyright © 2024 Razeware LLC. All rights reserved.
//

import UIKit

class RevealAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  let animationDuration = 0.7
  var operation: UINavigationController.Operation = .push
  
  weak var storedContext: UIViewControllerContextTransitioning?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return animationDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard operation == .push else {
      
      let fromVC = transitionContext.viewController(forKey: .from) as! DetailViewController
      let toVC = transitionContext.viewController(forKey: .to) as! MainViewController
      
      transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
      toVC.view.frame = transitionContext.finalFrame(for: toVC)
      
      UIView.animate(withDuration: animationDuration - 0.2, animations: {
        fromVC.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
      }, completion: { transitionContext.completeTransition($0) })
      
      return
    }
    
    storedContext = transitionContext
    
    let fromVC = transitionContext.viewController(forKey: .from) as! MainViewController
    let toVC = transitionContext.viewController(forKey: .to) as! DetailViewController
    
    transitionContext.containerView.addSubview(toVC.view)
    toVC.view.frame = transitionContext.finalFrame(for: toVC)
    
    let animation = CABasicAnimation(keyPath: "transform")
    animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
    animation.toValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0.0, -15.0, 0.0),
                                                                   CATransform3DMakeScale(150.0, 150.0, 1.0)))
    animation.duration = animationDuration
    animation.delegate = self
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
    
    let maskLayer = RWLogoLayer.logoLayer()
    maskLayer.position = fromVC.logo.position
    toVC.view.layer.mask = maskLayer
    maskLayer.add(animation, forKey: nil)
    
    fromVC.logo.add(animation, forKey: nil)
    
    let fadeAnimation = CABasicAnimation(keyPath: "opacity")
    fadeAnimation.duration = animationDuration
    fadeAnimation.fromValue = 0.0
    fadeAnimation.toValue = 1.0
    toVC.view.layer.add(fadeAnimation, forKey: nil)
  }
}

extension RevealAnimator: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if let storedContext {
      storedContext.completeTransition(!storedContext.transitionWasCancelled)
      (storedContext.viewController(forKey: .from) as! MainViewController).logo.removeAllAnimations()
      (storedContext.viewController(forKey: .to) as! DetailViewController).view.mask = nil
    }
    self.storedContext = nil
  }
}
