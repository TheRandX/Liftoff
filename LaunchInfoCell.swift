//
//  launchInfoCell.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 07/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

class LaunchInfoCell: UITableViewCell {
    
    
    @IBInspectable var lineWidth: CGFloat = 4
    @IBInspectable var radiusRatio: CGFloat = 0.1
    @IBInspectable var boundsOffset: CGFloat = 5
    
    @IBInspectable var fillColor = UIColor(red: 0.17, green: 0.25, blue: 0.38, alpha: 1.0)
    @IBInspectable var strokeColor = UIColor(red: 0.98, green: 0.62, blue: 0.26, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        
        let radius = radiusRatio * min(rect.height, rect.width)
        
        let newRect = CGRect(x: rect.minX + boundsOffset, y: rect.minY + boundsOffset, width: rect.width - 2 * boundsOffset, height: rect.height - 2 * boundsOffset)
        let path = UIBezierPath.init(roundedRect: newRect, cornerRadius: radius)
        
        path.lineWidth = lineWidth
        
        strokeColor.setStroke()
        path.stroke()
        
        fillColor.setFill()
        path.fill()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
