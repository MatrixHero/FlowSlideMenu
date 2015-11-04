//
//  LLFakeCurveView.swift
//
//  Created by LL on 15/11/1.
//  Copyright © 2015年 LL. All rights reserved.
//

import UIKit

public protocol LLFlowCurveViewDelegate : NSObjectProtocol
{
     func flowViewBeginBounce(flow:LLFlowCurveView)
//    func flowViewBeginAnimation(flow:LLFlowCurveView)
}

public class LLFlowCurveView : UIView
{
    
    weak public var delegate: LLFlowCurveViewDelegate?
    
    public var animating : Bool = false
    public enum Status {
        case OPEN
        case OPEN_ANI
        case OPEN_ALL
        case FINISH
    }
    
    var bgColor : UIColor = UIColor.blueColor()
    
    public struct FakeCurveOptions {
        public static var bgColor : UIColor = UIColor.whiteColor()
        public static var waveMargin : CGFloat = 100;
        public static var startRevealY : CGFloat = 300
     }
    
    public enum Orientation {
        case Left
    }
    
    var startpoint : CGPoint = CGPoint.zero;
    var endPoint : CGPoint = CGPoint.zero;
    
    var controlPoint1 : CGPoint = CGPoint.zero;
    var controlPoint2 : CGPoint = CGPoint.zero;
    var controlPoint3 : CGPoint = CGPoint.zero;
    var orientation : Orientation = .Left;
    
    var revealPoint : CGPoint = CGPoint.zero;
    
    var status : Status = .FINISH;
    
    var ani_reveal : CABasicAnimation  = CABasicAnimation()
    var ani_open : CABasicAnimation  = CABasicAnimation()
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
        self.revealPoint = CGPointMake(revealPoint.x - FakeCurveOptions.waveMargin, revealPoint.y)
        
        NSLog("revealx : %f", self.revealPoint.x)
        self.setNeedsDisplay()
    }
    
    public func start()
    {
        self.status = .OPEN
    }
    
    public func close()
    {
        self.status = .FINISH
    }
    public override func drawRect(rect: CGRect)
    {
       
            if (animating)
            {
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
        
        CGContextSetStrokeColorWithColor(context, FakeCurveOptions.bgColor.CGColor)
        CGContextSetLineWidth(context, 10)
        CGContextSetFillColorWithColor(context, FakeCurveOptions.bgColor.CGColor)

        
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
        NSLog("test:%f 开始点%@, 控制点1%@,控制点2%@",self.frame.size.width,NSStringFromCGPoint(self.startpoint),NSStringFromCGPoint(self.computeControlPoint(self.controlPoint1,bottom:true)),NSStringFromCGPoint(computeControlPoint(self.controlPoint1,bottom:false)))
        
    }

    public override class func layerClass() -> AnyClass
    {
        return LLFlowLayer.classForCoder()
    }
    
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
            if(a < 0){
                return CGPointMake(0 , point.y)
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
        return self.frame.size.width - FakeCurveOptions.waveMargin
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
    
    public func reset()
    {
        self.revealPoint = CGPointZero
        self.animating = false
    }
    
    private func getSpringAnimationWithTo(to:Float,from:Float,name:String) ->CASpringAnimation
    {
        let animation:CASpringAnimation = CASpringAnimation(keyPath: name)
        animation.toValue = Float(to)
        animation.fromValue = Float(from)
        animation.damping = 100
        animation.duration = animation.settlingDuration
        animation.stiffness = 100
        animation.mass = 1
        animation.initialVelocity = 0
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

    public func openAll()
    {
        if(self.animating == true)
        {
            return
        }
        self.animating = true
        
        self.status = .OPEN_ALL
        
        self.ani_reveal = getAnimationWithTo(Float(180 - FakeCurveOptions.waveMargin),from: Float(-FakeCurveOptions.waveMargin),duration:0.5,name: "reveal")
        
        self.revealPoint = CGPointMake(0,90)
        
        self.ani_reveal.delegate = self
        
        self.layer.addAnimation(self.ani_reveal, forKey: "open_frist")
    }
    
    public func open() {
    
        self.animating = true
        self.status = .OPEN_ANI
        
        self.ani_open = getAnimationWithTo(Float(getTo1()),from: Float(self.revealPoint.x),duration:0.5,name: "reveal")
        let ani_controlpoint : CABasicAnimation = getAnimationWithTo(Float(getTo1(self.controlPoint1.x)),from: Float(self.controlPoint1.x),duration:0.5,name:"control")
        let ani_startpoint : CABasicAnimation = getAnimationWithTo(Float(getTo1(self.startpoint.x)),from: Float(self.startpoint.x),duration:Float(0.5),name: "start")

        ani_open.delegate = self
        
        self.layer.addAnimation(self.ani_open, forKey: "open")
        self.layer.addAnimation(ani_controlpoint, forKey: "open2")
        self.layer.addAnimation(ani_startpoint, forKey: "open3")
        self.layer.removeAnimationForKey("open_frist")
    }
    
    
    public func bounce() {
        
        
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

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool)
    {

        if(anim ==  self.layer.animationForKey("open_frist"))
        {
            
            open()

        }else if(anim == self.layer.animationForKey("open"))
        {

            bounce()
            
        }else if(anim == self.layer.animationForKey("bounce"))
        {

            self.status = .FINISH
            
            reset()
            
            layer.removeAllAnimations()
            self.animating = false
            
            if(self.delegate != nil)
            {
                self.delegate?.flowViewBeginBounce(self)
            }
        }
        
        
    }
}
