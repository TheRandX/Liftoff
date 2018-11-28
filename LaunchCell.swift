//
//  LaunchCell.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 13/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import UIKit

@IBDesignable
class LaunchCell: UITableViewCell {
    
    @IBOutlet weak var rocketName: UILabel!
    //@IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBInspectable var lineWidth: CGFloat = 4
    @IBInspectable var radiusRatio: CGFloat = 0.2
    @IBInspectable var boundsOffset: CGFloat = 5
    
    @IBInspectable var fillColor = UIColor(red: 0.17, green: 0.25, blue: 0.38, alpha: 1.0)
    @IBInspectable var strokeColor = UIColor(red: 0.98, green: 0.62, blue: 0.26, alpha: 1.0)
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        let radius = CGFloat(radiusRatio) * min(rect.width, rect.height)
        
        let offsetMinX = rect.minX + boundsOffset
        let offsetMinY = rect.minY + boundsOffset
        let offsetMaxX = rect.maxX - boundsOffset
        let offsetMaxY = rect.maxY - boundsOffset
        
        path.move(to: CGPoint(x: offsetMinX, y: offsetMinY + radius))
        path.addArc(withCenter: CGPoint(x: offsetMinX + radius, y: offsetMinY + radius), radius: radius, startAngle: -.pi, endAngle: -.pi/2, clockwise: true)
        path.addLine(to: CGPoint(x: offsetMaxX - radius, y: offsetMinY))
        path.addArc(withCenter: CGPoint(x: offsetMaxX - radius, y: offsetMinY + radius), radius: radius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: offsetMaxX, y: offsetMaxY - radius))
        path.addArc(withCenter: CGPoint(x: offsetMaxX - radius, y: offsetMaxY - radius), radius: radius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        path.addLine(to: CGPoint(x: offsetMinX + radius, y: offsetMaxY))
        path.addArc(withCenter: CGPoint(x: offsetMinX + radius, y: offsetMaxY - radius), radius: radius, startAngle: .pi/2, endAngle: -.pi, clockwise: true)
        path.close()
        path.lineWidth = lineWidth
        
        strokeColor.setStroke()
        path.stroke()
        
        fillColor.setFill()
        path.fill()
        
        
        
    }
    
}
