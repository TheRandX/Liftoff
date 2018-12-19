//
//  OvalVIew.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 18/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

@IBDesignable
class OvalView: UIView {
    
    @IBInspectable var lineWidth: CGFloat = 4
    @IBInspectable var radiusRatio: CGFloat = 0.1
    @IBInspectable var boundsOffset: CGFloat = 0
    @IBInspectable var fillColor: UIColor? = nil
    @IBInspectable var strokeColor: UIColor? = nil
    
    override func draw(_ rect: CGRect) {
        
        let radius = CGFloat(radiusRatio) * min(rect.width, rect.height)
        let newRect = CGRect(x: rect.minX + boundsOffset, y: rect.minY + boundsOffset, width: rect.width - 2 * boundsOffset, height: rect.height - 2 * boundsOffset)
        let path = UIBezierPath.init(roundedRect: newRect, cornerRadius: radius)
        
        if let color = strokeColor {
            path.lineWidth = lineWidth
            color.setStroke()
            path.stroke()
        }
        
        if let color = fillColor {
            color.setFill()
            path.fill()
        }
        
    }
    
}
