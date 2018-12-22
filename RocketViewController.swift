//
//  RocketViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 19/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

class RocketViewController: SegmentedViewController {

    @IBOutlet weak var rocketInfoLabel: UILabel!
    @IBOutlet weak var rocketImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let vc = super.superclass as? UIViewController? {
            vc?.viewWillAppear(animated)
        }
        
        dataSource?.rocketData(rocketInfo: rocketInfoLabel, rocketImage: rocketImageView)
        
    }
    
}
