//
//  SegmentedViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 19/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {

    var dataSource: SegmentedDataSource?
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let childvc = self as? MissionViewController {
            childvc.viewWillAppear(animated)
        } else if let childvc = self as? RocketViewController {
            childvc.viewWillAppear(animated)
        } else if let childvc = self as? LocationViewController {
            childvc.viewWillAppear(animated)
        }
    }
    
}
