//
//  LLFakeCurveView.swift
//
//  Created by LL on 15/11/1.
//  Copyright © 2015 LL. All rights reserved.
//

import UIKit
import QuartzCore

public class LLFlowCurveView : UIView
{
    weak public var delegate: LLFlowCurveViewDelegate?
    
    public var animating : Bool = false
    
    public enum Status {
        case OPEN
        case OPEN_ANI
        case OPEN_ALL
        case FINISH
        case CLOSE
    }
    
    var bgColor : UIColor = UIColor.blueColor()
    
   
    
    var startpoint : CGPoint = CGPoint.zero;
    var endPoint : CGPoint = CGPoint.zero;
    
    var controlPoint1 : CGPoint = CGPoint.zero;
    var controlPoint2 : CGPoint = CGPoint.zero;
    var controlPoint3 : CGPoint = CGPoint.zero;
    var orientation : Orientation = .Left;
    
    var revealPoint : CGPoint = CGPoint.zero;
    
    var status : Status = .CLOSE;
    
    // MARK: -
    // MARK: lifecycle
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        layer.opaque = false
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func updatePoint(revealPoint:CGPoint,
        orientation:Orientation
        )
    {
        self.revealPoint = revealPoint
        self.setNeedsDisplay()
    }

    public override func drawRect(rect: CGRect)
    {
        if (animating){
            let layer :LLFlowLayer = self.layer.presentationLayer() as! LLFlowLayer
                
            self.revealPoint = CGPointMake(layer.reveal, self.revealPoint.y)
                
            if(self.status == .OPEN_ANI)
            {
                self.controlPoint1 = CGPointMake(layer.control, self.controlPoint1.y)
                self.controlPoint3 =  CGPointMake(layer.control, self.controlPoint3.y)
                self.startpoint = CGPointMake(layer.start, self.startpoint.y)
                self.endPoint =  CGPointMake(layer.start, self.endPoint.y)
                    
            }
            if(self.status == .OPEN_ALL)
            {
                computePoints()
            }
        }else
        {
            computePoints()
        }
        
        
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        CGContextSetStrokeColorWithColor(context, FlowCurveOptions.bgColor.CGColor)
        CGContextSetLineWidth(context, 10)
        CGContextSetFillColorWithColor(context, FlowCurveOptions.bgColor.CGColor)

        
        let path : UIBezierPath = UIBezierPath()
        
        path.moveToPoint(CGPointMake(0, self.startpoint.y))
        path.addLineToPoint(self.startpoint)
       
        path.moveToPoint(self.startpoint)
        path.addCurveToPoint(self.controlPoint2, controlPoint1: self.computeControlPoint(self.controlPoint1,bottom:true), controlPoint2: self.computeControlPoint(self.controlPoint1,bottom: false))
        path.addLineToPoint(CGPointMake(0, self.controlPoint2.y))
        path.addLineToPoint(CGPointMake(0, self.startpoint.y))
        path.addLineToPoint(self.startpoint)
        
        path.moveToPoint(self.controlPoint2)
        path.addCurveToPoint(self.endPoint, controlPoint1: self.computeControlPoint(self.controlPoint3,bottom: false), controlPoint2: self.computeControlPoint(self.controlPoint3,bottom: true))
        
        path.moveToPoint(self.endPoint)
        path.addLineToPoint(CGPointMake(0, self.endPoint.y))
        path.addLineToPoint(CGPointMake(0, self.controlPoint2.y))
        path.addLineToPoint(self.controlPoint2)
        
        path.stroke()
        path.fill()
    }

    public override class func layerClass() -> AnyClass
    {
        return LLFlowLayer.classForCoder()
    }
    
    // MARK: -
    // MARK: private funs
    
    // MARK: compute points funs
    private func computeControlPoint(point : CGPoint , bottom : Bool) -> CGPoint
    {
        if(self.status == .FINISH)
        {
            return CGPointMake(self.getWidth(), point.y)
        }
        if(bottom)
        {
            let a : CGFloat =  revealPoint.x/self.controlPoint1.x
            let maxRatio :CGFloat = 0.7
            if(a > maxRatio && status != .OPEN_ANI )
            {
                return CGPointMake(getMidPointX() * maxRatio, point.y)
            }
            return CGPointMake(getMidPointX()*a , point.y)
        }
        
        return CGPointMake(self.getMidPointX(), point.y)
    }
    
    private func getWaveWidth() -> CGFloat
    {
        return getHeight() * 2
    }
    
    public func getWidth() -> CGFloat
    {
        return self.frame.size.width - FlowCurveOptions.waveMargin
    }
    
    private func getHeight() -> CGFloat
    {
        return self.frame.size.height
    }
    
    private func getStartPoint() -> CGPoint
    {
        
        let x : CGFloat = 0
        let y : CGFloat = self.getHeight()/2 - getWaveWidth()/2
        if(self.status == .FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    private func getEndPoint() -> CGPoint
    {
        let x : CGFloat = 0
        let y : CGFloat = self.getHeight()/2 + getWaveWidth()/2
        
        if(self.status == .FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    private func getControlPoint1() -> CGPoint
    {
        let x : CGFloat = getMidPointX()/2
        let y : CGFloat = getMidPointY() - (getWaveWidth()/10 * self.revealPoint.x/self.getWidth()) - getWaveWidth()/20
        if(self.status == .FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    public func getControlPoint2() -> CGPoint
    {
        let x : CGFloat = self.getMidPointX()
        let y : CGFloat = self.revealPoint.y
        if(self.status == .FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    private func getControlPoint3() -> CGPoint
    {
        let x : CGFloat = getMidPointX()/2
        let y : CGFloat = getMidPointY() + (getWaveWidth()/10 * self.revealPoint.x/self.getWidth()) + getWaveWidth()/20
        
        if(self.status == .FINISH)
        {
            return CGPointMake(getWidth(), y)
        }
        return CGPointMake(x,y)
    }
    
    //start point
    private func getMidPointY() -> CGFloat
    {
        return self.revealPoint.y
    }
    
    //start point
    private func getMidPointX() -> CGFloat
    {
        return getWidth()
    }
    
    private func computePoints()
    {
        
        self.startpoint = self.getStartPoint()
        self.endPoint = self.getEndPoint()
        self.controlPoint1 = self.getControlPoint1()
        self.controlPoint2 = self.getControlPoint2()
        self.controlPoint3 = self.getControlPoint3()
    }
    
    private func getTo1(float:CGFloat) -> CGFloat
    {
        let to : CGFloat = getWidth() - float
        return to
    }
    
    private func getTo1() -> CGFloat
    {
        let to : CGFloat = getWidth()
        return to
    }
    
    public func reset()
    {
        self.revealPoint = CGPointZero
        self.animating = false
    }
    
    // MARK: get animation
    private func getSpringAnimationWithTo(to:Float,from:Float,name:String) ->CASpringAnimation
    {
        let animation:CASpringAnimation = CASpringAnimation(keyPath: name)
        animation.toValue = Float(to)
        animation.fromValue = Float(from)
        animation.damping = FlowCurveOptions.animation_damping
        animation.duration = animation.settlingDuration
        animation.stiffness = FlowCurveOptions.animation_stiffness
        animation.mass = FlowCurveOptions.animation_mass
        animation.initialVelocity = FlowCurveOptions.animation_initialVelocity
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.removedOnCompletion = false
        return animation
    }
    
    private func getAnimationWithTo(to:Float,from:Float,duration:Float,name:String) ->CABasicAnimation
    {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: name)
        animation.toValue = Float(to)
        animation.fromValue = Float(from)
        animation.duration = Double(duration)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        return animation
    }
    
     // MARK: animations
    private func open(delay:Double)
    {
        let ani_open : CABasicAnimation  = getAnimationWithTo(Float(getTo1()),from: Float(self.getWidth()/2),duration:Float(FlowCurveOptions.animation_open),name: "reveal")
        let ani_controlpoint : CABasicAnimation = getAnimationWithTo(Float(getTo1(self.getWidth()/2)),from: Float(self.getWidth()/2),duration:Float(FlowCurveOptions.animation_open),name:"control")
        let ani_startpoint : CABasicAnimation = getAnimationWithTo(Float(getTo1(0)),from: Float(0),duration:Float(FlowCurveOptions.animation_open),name: "start")
        
        ani_open.beginTime = CACurrentMediaTime() + delay
        ani_controlpoint.beginTime = CACurrentMediaTime() + delay
        ani_startpoint.beginTime = CACurrentMediaTime() + delay
        
        self.layer.addAnimation(ani_open, forKey: "open")
        self.layer.addAnimation(ani_controlpoint, forKey: "open2")
        self.layer.addAnimation(ani_startpoint, forKey: "open3")
    }
    
    private func bounce(delay:Double) {
        
        let ani_reveal  : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(getTo1()),name:"reveal")
        let ani_controlpoint : CABasicAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(getTo1(self.getWidth()/2)),name:"control")
        let ani_startpoint : CABasicAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(getTo1(0)),name:"start")
        
        
        ani_reveal.beginTime = CACurrentMediaTime() + delay
        ani_controlpoint.beginTime = CACurrentMediaTime() + delay
        ani_startpoint.beginTime = CACurrentMediaTime() + delay
        
        ani_reveal.delegate = self
        
        self.layer.addAnimation(ani_reveal, forKey: "bounce")
        self.layer.addAnimation(ani_controlpoint, forKey: "bounce2")
        self.layer.addAnimation(ani_startpoint, forKey: "bounce3")
        
    }
    
    private func bounce() {
        
        let ani_reveal  : CASpringAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(revealPoint.x),name:"reveal")
        let ani_controlpoint : CABasicAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(controlPoint1.x),name:"control")
        let ani_startpoint : CABasicAnimation = getSpringAnimationWithTo(Float(getTo1()),from: Float(startpoint.x),name:"start")
        
        ani_reveal.delegate = self
        
        self.layer.addAnimation(ani_reveal, forKey: "bounce")
        self.layer.addAnimation(ani_controlpoint, forKey: "bounce2")
        self.layer.addAnimation(ani_startpoint, forKey: "bounce3")
        
        self.layer.removeAnimationForKey("open")
        self.layer.removeAnimationForKey("open2")
        self.layer.removeAnimationForKey("open3")
    }
    
    private func finish()
    {
        if (self.layer.animationKeys() != nil && (self.layer.animationKeys()!.count > 0))
        {
            NSLog("finish")
            layer.removeAllAnimations()
            self.animating = false
            reset()
            self.status = .FINISH
            notifyDelegateAnimationEnd()
        }
    }
    
    
    private func notifyDelegateAnimationStart()
    {
        if(self.delegate != nil)
        {
            self.delegate?.flowViewStartAnimation(self)
        }
    }
    
    private func notifyDelegateAnimationEnd()
    {
        if(self.delegate != nil)
        {
            self.delegate?.flowViewEndAnimation(self)
        }
    }
    
    // MARK: -
    // MARK: public funs
    public func openAll()
    {
        if(self.animating == true)
        {
            return
        }
        self.layer.removeAllAnimations()
        notifyDelegateAnimationStart()
        
        self.animating = true
        
        self.status = .OPEN_ALL
        
        let ani_reveal : CABasicAnimation = getAnimationWithTo(Float(self.getWidth()/2
            ),from: Float(0),duration:Float(FlowCurveOptions.animation_reveal),name: "reveal")
        
        self.revealPoint = CGPointMake(0,FlowCurveOptions.startRevealY)
        
        ani_reveal.delegate = self
        
        self.layer.addAnimation(ani_reveal, forKey: "openfrist")

        open(FlowCurveOptions.animation_reveal)
    
        bounce(FlowCurveOptions.animation_reveal + FlowCurveOptions.animation_open)
    }
    
    public func open() {
    
        if(self.status != .OPEN)
        {
            return
        }
        
        self.layer.removeAllAnimations()
        notifyDelegateAnimationStart()
        
        self.animating = true
        self.status = .OPEN_ANI
    
        let ani_open : CABasicAnimation  = getAnimationWithTo(Float(getTo1()),from: Float(self.revealPoint.x),duration:Float(FlowCurveOptions.animation_open),name: "reveal")
        let ani_controlpoint : CABasicAnimation = getAnimationWithTo(Float(getTo1(self.controlPoint1.x)),from: Float(self.controlPoint1.x),duration:Float(FlowCurveOptions.animation_open),name:"control")
        let ani_startpoint : CABasicAnimation = getAnimationWithTo(Float(getTo1(self.startpoint.x)),from: Float(self.startpoint.x),duration:Float(FlowCurveOptions.animation_open),name: "start")

        ani_open.delegate = self
        
        self.layer.addAnimation(ani_open, forKey: "open")
        self.layer.addAnimation(ani_controlpoint, forKey: "open2")
        self.layer.addAnimation(ani_startpoint, forKey: "open3")
    }
    
    public func start()
    {
        if(self.status == .CLOSE)
        {
            self.status = .OPEN
            self.frame.origin.x = self.frame.origin.x + FlowCurveOptions.waveMargin
        }
    }
    
    public func close()
    {
        self.status = .CLOSE
        self.reset()
        self.layer.removeAllAnimations()
    }
    
    // MARK: -
    // MARK: caanimation delegate
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool)
    {
        if(anim ==  self.layer.animationForKey("openfrist"))
        {
            self.status = .OPEN_ANI
        }else if(anim == self.layer.animationForKey("open"))
        {
            bounce()
        }else if(anim == self.layer.animationForKey("bounce"))
        {
            finish()
        }
    }
}
