//
//  ViewController.swift
//  Breakout
//
//  Created by nevercry on 10/13/15.
//  Copyright © 2015 nevercry. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    struct Constans {
        static let BallSize: CGFloat = 40.0
        static let BallColor = UIColor.blueColor()
        
        static let PaddleSize = CGSize(width: 80.0, height: 20.0)
        static let PaddleCornerRadius: CGFloat = 5.0
        static let PaddleColor = UIColor.greenColor()
        
        static let BrickColumns = 10
        static let BrickRows = 8
        static let BrickTotalWidth: CGFloat = 1.0
        static let BrickTotalHeight: CGFloat = 0.3
        static let BrickTopSpacing: CGFloat = 0.05
        static let BrickSpacing: CGFloat = 5.0
        static let BrickCornerRadius: CGFloat = 2.5
        static let BrickColors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor()]
        
        static let BoxPathName = "Box"
        static let PaddlePathName = "Paddle"
    }

    @IBOutlet weak var gameView: UIView!
    
    var breakout = BreakoutBehavior()
    
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView) }()
    
    lazy var paddle: UIView = {
        let paddle = UIView(frame: CGRect(origin: CGPoint(x: -1, y: -1), size: Constans.PaddleSize))
        paddle.backgroundColor = Constans.PaddleColor
        paddle.layer.cornerRadius = Constans.PaddleCornerRadius
        paddle.layer.borderColor = UIColor.blackColor().CGColor
        paddle.layer.borderWidth = 2.0
        paddle.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        paddle.layer.shadowOpacity = 0.5
        
        self.gameView.addSubview(paddle)
        
        return paddle
    }()
    
    private var bricks = [Int:Brick]()
    
    private struct Brick {
        var relativeFrame: CGRect
        var view: UIView
        var action: BrickAction
    }
    
    private typealias BrickAction = ((Int) -> Void)?
    
    private var autoStartTimer: NSTimer?
    
    // MARK: - Lifecycle
    
    private func levelOne() {
        if bricks.count > 0 { return }
        
        let deltaX = Constans.BrickTotalWidth / CGFloat(Settings().columns!)
        let deltaY = Constans.BrickTotalHeight / CGFloat(Settings().rows!)
        var frame = CGRect(origin: CGPointZero, size: CGSize(width: deltaX, height: deltaY))
        
        for row in 0..<Settings().rows! {
            for column in 0..<Settings().columns! {
                frame.origin.x = deltaX * CGFloat(column)
                frame.origin.y = deltaY * CGFloat(row) + Constans.BrickTopSpacing
                let brick = UIView(frame: frame)
                brick.backgroundColor = Constans.BrickColors[row % Constans.BrickColors.count]
                brick.layer.cornerRadius = Constans.BrickCornerRadius
                brick.layer.borderColor = UIColor.blackColor().CGColor
                brick.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
                brick.layer.shadowOpacity = 0.1
                
                gameView.addSubview(brick)
                
                var action: BrickAction = nil
                
                if Settings().difficulty == 1 {
                    if row + 1 == Settings().rows! {
                        brick.backgroundColor = UIColor.blackColor()
                        action = { index in
                            if brick.backgroundColor != UIColor.blackColor() {
                                self.destroyBrickAtIndex(index)
                            } else {
                                NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "changeBrickColor:", userInfo: brick, repeats: false)
                            }
                        }
                    }
                }
                
                
                bricks[row * Settings().columns! + column] = Brick(relativeFrame: frame, view: brick, action: action)
            }
            
        }
    }
    
    func changeBrickColor(timer: NSTimer) {
        if let brick = timer.userInfo as? UIView {
            UIView.animateWithDuration(0.5, animations: {
                brick.backgroundColor = UIColor.cyanColor()
            })
        }
    }
    
    private func levelFinished() {
        autoStartTimer?.invalidate()
        autoStartTimer = nil
        for ball in breakout.balls {
            breakout.removeBall(ball)
        }
        
        let alertController = UIAlertController(title: "Game Over", message: "", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Play Again", style: .Default, handler: { (aciton) in
            self.levelOne()
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakout)
        
        _ = Settings(defaultColumns: Constans.BrickColumns, defaultRows: Constans.BrickRows, defaultBalls: 1, defaultDifficulty: 0)
        
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pushBall:"))
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipePaddleLeft:")
        swipeLeft.direction = .Left
        gameView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipePaddleRight:")
        swipeRight.direction = .Right
        gameView.addGestureRecognizer(swipeRight)
        
        breakout.collisionDelegate = self
        levelOne()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var rect = gameView.bounds
        rect.size.height *= 2
        breakout.addBarrier(UIBezierPath(rect: rect), named: Constans.BoxPathName)
        
        placeBricks()
        resetPaddle()
        
        for ball in breakout.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Settings().changed {
            Settings().changed = false
            for (_, brick) in bricks {
                brick.view.removeFromSuperview()
            }
            bricks.removeAll(keepCapacity: true)
            
            for ball in breakout.balls {
                ball.removeFromSuperview()
            }
            
            animator.removeAllBehaviors()
            breakout = BreakoutBehavior()
            animator.addBehavior(breakout)
            breakout.collisionDelegate = self
            breakout.speed = CGFloat(Settings().speed)
            
            levelOne()
        }
        
        setAutoStartTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        autoStartTimer?.invalidate()
        autoStartTimer = nil
    }
    
    private func setAutoStartTimer() {
        if Settings().autoStart {
            autoStartTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "autoStart:", userInfo: nil, repeats: true)
        }
    }
    
    func autoStart(timer: NSTimer) {
        if breakout.balls.count < Settings().balls {
            let ball = createBall()
            placeBall(ball)
            breakout.addBall(ball)
            breakout.pushBall(breakout.balls.last!)
        }
    }
    
    // MARK: - ball
    
    func placeBall(ball: UIView) {
        ball.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.midY)
    }
    
    func pushBall(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            if breakout.balls.count < Settings().balls {
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
    
    // MARK: - paddle
    
    func resetPaddle() {
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - paddle.bounds.height)
        } else {
            paddle.center = CGPoint(x: paddle.center.x, y: gameView.bounds.maxY - paddle.bounds.height)
        }
        addPaddleBarrier()
    }
    
    func placePaddle(translation: CGPoint) {
        var origin = paddle.frame.origin
        origin.x = max(min(origin.x + translation.x, gameView.bounds.maxX - Constans.PaddleSize.width), 0,0)
        paddle.frame.origin = origin
        addPaddleBarrier()
    }
    
    func addPaddleBarrier() {
        breakout.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constans.PaddleCornerRadius), named: Constans.PaddlePathName)
    }
    
    func panPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            placePaddle(gesture.translationInView(gameView))
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    
    func swipePaddleLeft(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            placePaddle(CGPoint(x: -gameView.bounds.maxX, y: 0.0))
        default: break
        }
    }
    
    func swipePaddleRight(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            placePaddle(CGPoint(x: gameView.bounds.maxX, y: 0.0))
        default: break
        }
    }
    
    // MARK: - bricks
    
    private func placeBricks() {
        for (index, brick) in bricks {
            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width
            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height
            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
            brick.view.frame = CGRectInset(brick.view.frame, Constans.BrickSpacing, Constans.BrickSpacing)
            breakout.addBarrier(UIBezierPath(roundedRect: brick.view.frame, cornerRadius: Constans.BrickCornerRadius), named: index)
        }
    }
    
    // MARK: - UICollisionBehaviorDelegate
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let index = identifier as? Int {
            if let action = bricks[index]?.action {
                action(index)
            } else {
                destroyBrickAtIndex(index)
            }
        }
    }
    
    private func destroyBrickAtIndex(index: Int) {
        breakout.removeBarrier(index)
        if let brick = bricks[index] {
            UIView.transitionWithView(brick.view, duration: 0.2, options: .TransitionFlipFromBottom, animations: {
                brick.view.alpha = 0.5
                }, completion: {
                    (success) -> Void in
                    self.breakout.addBrick(brick.view)
                    UIView.animateWithDuration(1.0, animations: {
                        brick.view.alpha = 0.0
                        }, completion: {
                            (success) -> Void in
                            self.breakout.removeBrick(brick.view)
                            brick.view.removeFromSuperview()
                            if self.bricks.count == 0 {
                                self.levelFinished()
                            }
                    })
            })
            bricks.removeValueForKey(index)
        }
    }
    
}

