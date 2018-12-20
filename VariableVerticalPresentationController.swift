//
//  VariableVerticalPresentationController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 20/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

class VariableVerticalPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            return CGRect(x: 0, y: 375, width: containerView?.bounds.width ?? 0, height: (containerView?.bounds.height ?? 0) / 2)
        }
    }

}
