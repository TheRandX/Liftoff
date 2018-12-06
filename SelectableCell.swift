//
//  MissionCell.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 06/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit
import ExpandableCell

class SelectableCell: ExpandableCell {
    
    
    override func layoutSubviews() {
        rightMargin = bounds.maxX*0.15
        super.layoutSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.autoresizingMask = .flexibleWidth
        contentView.autoresizesSubviews = true
    }

    /*override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/

    override func isSelectable() -> Bool {
        return true
    }
}
