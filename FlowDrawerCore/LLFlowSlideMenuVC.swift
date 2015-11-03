//
//  LLFlowSlideMenuVC
//
//  Created by LL on 15/10/31.
//  Copyright © 2015年 LL. All rights reserved.
//

import UIKit
import QuartzCore

public class LLFlowSlideMenuVC : UIViewController, UIGestureRecognizerDelegate ,LLFlowCurveViewDelegate
{
    
    public struct FlowDrawerOptions {
        public static var leftViewWidth: CGFloat = 300.0
        public static var leftBezelWidth: CGFloat = 100.0
        public static var contentViewScale: CGFloat = 0.96
        public static var contentViewOpacity: CGFloat = 0.5
        public static var shadowOpacity: CGFloat = 0.0
        public static var shadowRadius: CGFloat = 0.0
        public static var shadowOffset: CGSize = CGSizeMake(0,0)
        public static var panFromBezel: Bool = true
        public static var animationDuration: CGFloat = 0.5
        public static var hideStatusBar: Bool = true
        public static var pointOfNoReturnWidth: CGFloat = 150.0
        public static var opacityViewBackgroundColor: UIColor = UIColor.blackColor()
    }
    
    public enum SlideAction {
        case Open
        case Close
    }
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    // MARK: -
    // MARK: parms
    public var leftViewController: UIViewController?
    public var mainViewController: UIViewController?
    
    public var opacityView = UIView()
    public var mainContainerView = UIView()
    public var leftContainerView = LLFlowCurveView()
    
    public var leftPanGesture: UIPanGestureRecognizer?
    public var leftTapGetsture: UITapGestureRecognizer?
    
    
    // MARK: -
    // MARK: lifecycle
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(mainViewController: UIViewController,leftViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        self.leftViewController = leftViewController
        initView()

    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        leftContainerView.hidden = true
        
        coordinator.animateAlongsideTransition(nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.closeLeftNonAnimation()

            self.leftContainerView.hidden = false

            
            if self.leftPanGesture != nil && self.leftPanGesture != nil {
                self.removeLeftGestures()
                self.addLeftGestures()
            }
            
        })
    }
  
    public override func viewWillLayoutSubviews() {
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        leftViewController?.view.alpha = 0.0
    }
    
    deinit { }
    
    // MARK: -
    // MARK: private funs
    
    func initView() {
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clearColor()
        mainContainerView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        view.insertSubview(mainContainerView, atIndex: 0)
        
        var opacityframe: CGRect = view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = FlowDrawerOptions.opacityViewBackgroundColor
        opacityView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, atIndex: 1)
        
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = FlowDrawerOptions.leftViewWidth
        leftFrame.origin.x = leftMinOrigin();
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView = LLFlowCurveView(frame: leftFrame)
        leftContainerView.backgroundColor = UIColor.clearColor()
        leftContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        leftContainerView.delegate = self
        view.insertSubview(leftContainerView, atIndex: 2)
        addLeftGestures()

    }
    
    private func setUpViewController(targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            addChildViewController(viewController)
            viewController.view.frame = targetView.bounds
            targetView.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    
    private func removeViewController(viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.willMoveToParentViewController(nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    private func leftMinOrigin() -> CGFloat {
        return  -FlowDrawerOptions.leftViewWidth
    }
    
    private func isLeftPointContainedWithinBezelRect(point: CGPoint) -> Bool{
        var leftBezelRect: CGRect = CGRectZero
        var tempRect: CGRect = CGRectZero
        let bezelWidth: CGFloat = FlowDrawerOptions.leftBezelWidth
        
        CGRectDivide(view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectEdge.MinXEdge)
        return CGRectContainsPoint(leftBezelRect, point)
    }
    
    private func addLeftGestures() {
        
        if (leftViewController != nil) {
            if leftPanGesture == nil {
                leftPanGesture = UIPanGestureRecognizer(target: self, action: "handleLeftPanGesture:")
                leftPanGesture!.delegate = self
                view.addGestureRecognizer(leftPanGesture!)
            }
            
//            if leftTapGetsture == nil {
//                leftTapGetsture = UITapGestureRecognizer(target: self, action: "toggleLeft")
//                leftTapGetsture!.delegate = self
//                view.addGestureRecognizer(leftTapGetsture!)
//            }
        }
    }
    

    
    private func panLeftResultInfoForVelocity(velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + FlowDrawerOptions.pointOfNoReturnWidth
        let leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .Close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .Close : .Open;
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .Open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .Close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    public func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return true
    }
    
    private func slideLeftForGestureRecognizer( gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || FlowDrawerOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    private func isPointContainedWithinLeftRect(point: CGPoint) -> Bool {
        return CGRectContainsPoint(leftContainerView.frame, point)
    }
    
    private func applyLeftTranslation(translation: CGPoint, toFrame:CGRect) -> CGRect {
        
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = leftMinOrigin()
        let maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    
    private func setOpenWindowLevel() {
        if (FlowDrawerOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    private func setCloseWindowLebel() {
        if (FlowDrawerOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    public func isLeftOpen() -> Bool {
        return leftContainerView.frame.origin.x == 0.0
    }
    
    public func isLeftHidden() -> Bool {
        return leftContainerView.frame.origin.x <= leftMinOrigin()
    }
    
    public func closeLeftWithVelocity(velocity: CGFloat) {
        
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = leftMinOrigin()
        
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        
        var duration: NSTimeInterval = Double(FlowDrawerOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
//                    strongSelf.removeShadow(strongSelf.leftContainerView)
                    strongSelf.enableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                    strongSelf.leftViewController?.view.alpha=0.0
                    if(Bool)
                    {
                        strongSelf.leftContainerView.status = LLFlowCurveView.Status.OPEN
                        strongSelf.leftContainerView.reset()
                    }
                }
        }
    }
    
    public func openLeft (){
        self.leftContainerView.open()
        openLeftWithVelocity(0.0)
    }
    
    public func openLeftWithVelocity(velocity: CGFloat) {
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame;
        frame.origin.x = finalXOrigin;
        
        var duration: NSTimeInterval = Double(FlowDrawerOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
//        addShadowToView(leftContainerView)
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(FlowDrawerOptions.contentViewOpacity)
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(FlowDrawerOptions.contentViewScale, FlowDrawerOptions.contentViewScale)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
    }

    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    private func openCurve() {
        self.leftContainerView.open()
    }
    
    // MARK: -
    // MARK: public funs
    public func removeLeftGestures() {
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
    }
    
    public func closeLeftNonAnimation(){
        setCloseWindowLebel()
        let finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
//        removeShadow(leftContainerView)
        enableContentInteraction()
        self.leftContainerView.animating = false
    }
    
    private func disableContentInteraction() {
        mainContainerView.userInteractionEnabled = false
    }
    
    private func enableContentInteraction() {
        mainContainerView.userInteractionEnabled = true
    }
    
    // MARK: -
    // MARK: handleLeftPanGesture funs
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRectZero
        static var startPointOfPan: CGPoint = CGPointZero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    func handleLeftPanGesture(panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }


        switch panGesture.state {
        case UIGestureRecognizerState.Began:
            
            LeftPanState.frameAtStartOfPan = leftContainerView.frame
            LeftPanState.startPointOfPan = panGesture.locationInView(view)
            LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
            LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
            
            leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
            setOpenWindowLevel()
        case UIGestureRecognizerState.Changed:
            
            let translation: CGPoint = panGesture.translationInView(panGesture.view!)
            leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
            leftContainerView.backgroundColor = UIColor.clearColor()
            leftContainerView.updatePoint(CGPointMake(translation.x -  LeftPanState.startPointOfPan.x, translation.y +  LeftPanState.startPointOfPan.y), orientation: LLFlowCurveView.Orientation.Left)
        case UIGestureRecognizerState.Ended:
            
            let velocity:CGPoint = panGesture.velocityInView(panGesture.view)
            let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
            
            if panInfo.action == .Open {
                if !LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(true, animated: true)
                }
                
                openLeftWithVelocity(panInfo.velocity)
                openCurve()
                
            } else {
                if LeftPanState.wasHiddenAtStartOfPan {
                    leftViewController?.beginAppearanceTransition(false, animated: true)
                }
                closeLeftWithVelocity(panInfo.velocity)
                setCloseWindowLebel()
                
            }
        default:
            break
        }
    }
    
    // MARK:  -
    // MARK: UIGestureRecognizerDelegate
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        let point: CGPoint = touch.locationInView(view)
        
        if gestureRecognizer == leftPanGesture {
            return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        } else if gestureRecognizer == leftTapGetsture {
            return isLeftOpen() && !isPointContainedWithinLeftRect(point)
        }
    
        return true
    }
    
    // MARK:  -
    // MARK: LLFlowCurveViewDelegate
    public func flowViewBeginBounce(flow:LLFlowCurveView)
    {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.leftViewController?.view.alpha = 1
        }
        
    }
}