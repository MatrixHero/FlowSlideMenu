//
//  LLFlowSlideMenuConfig.swift
//  FlowSlideMenu
//
//  Created by LL on 15/11/5.
//  Copyright © 2015 LL. All rights reserved.
//

import UIKit

public struct FlowSlideMenuOptions {
    public static var leftViewWidth: CGFloat = 200.0
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

public struct FlowCurveOptions {
    //background color for animation view
    public static var bgColor : UIColor = UIColor.whiteColor()
    //the wave cloud be floating so have to make margin
    public static var waveMargin : CGFloat = 100
    //the auto open point which is start Y
    public static var startRevealY : CGFloat = 300
    //animation duration total time
    public static var animation_reveal:Double = 0.3
    //animation duration time for open
    public static var animation_open:Double = 0.1
    //animation damping factor
    public static var animation_damping:CGFloat = 10
    //animation stiffness factor
    public static var animation_stiffness:CGFloat = 100
    //animation mass factor
    public static var animation_mass:CGFloat = 1
    //animation initial velocity
    public static var animation_initialVelocity:CGFloat = 10
}


