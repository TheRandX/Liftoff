//
//  ViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 19/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit

class MissionViewController: SegmentedViewController {
    
    @IBOutlet weak var missionPurposeLabel: UILabel!
    @IBOutlet weak var missionDescriptionLabel: UILabel!
    @IBOutlet weak var blurView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let vc = super.superclass as? UIViewController? {
            vc?.viewWillAppear(animated)
        }
        
        dataSource?.missionData(missionType: missionPurposeLabel, missionDescription: missionDescriptionLabel)
        
    }

}
