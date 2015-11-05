//
//  LLFlowCurveProtocol.swift
//  FlowSlideMenu
//
//  Created by LL on 15/11/5.
//  Copyright © 2015年 LL. All rights reserved.
//

import UIKit

@objc public protocol LLFlowCurveViewDelegate : NSObjectProtocol
{
    func flowViewStartAnimation(flow:LLFlowCurveView)
    
    func flowViewEndAnimation(flow:LLFlowCurveView)
}
