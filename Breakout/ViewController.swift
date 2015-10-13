//
//  ViewController.swift
//  Breakout
//
//  Created by nevercry on 10/13/15.
//  Copyright © 2015 nevercry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    struct Constans {
        static let BallSize: CGFloat = 40.0
        static let BallColor = UIColor.blueColor()
        
        static let BoxPathName = "Box"
    }

    @IBOutlet weak var gameView: UIView!
    
    let breakout = BreakoutBehavior()
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakout)
        
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pushBall:"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var rect = gameView.bounds
        rect.size.height *= 2
        breakout.addBarrier(UIBezierPath(rect: rect), named: Constans.BoxPathName)
        
        for ball in breakout.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
    }
    
    // MARK: - ball
    
    func placeBall(ball: UIView) {
        ball.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.midY)
    }
    
    func pushBall(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            if breakout.balls.count == 0 {
                let ball = createBall()
                placeBall(ball)
                breakout.addBall(ball)
            }
            breakout.pushBall(breakout.balls.last!)
        }
    }
    
    func createBall() -> UIView {
        let ball = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: Constans.BallSize, height: Constans.BallSize)))
        ball.backgroundColor = Constans.BallColor
        ball.layer.cornerRadius = Constans.BallSize / 2.0
        ball.layer.borderColor = UIColor.blackColor().CGColor
        ball.layer.borderWidth = 2.0
        ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        ball.layer.shadowOpacity = 0.5
        return ball
    }
    
    
    
}

