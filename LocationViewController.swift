//
//  LocationViewController.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 19/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: SegmentedViewController {

    @IBOutlet weak var locationMap: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let vc = super.superclass as? UIViewController? {
            vc?.viewWillAppear(animated)
        }
        locationMap.isScrollEnabled = false
        locationMap.layer.masksToBounds = true
        locationMap.layer.cornerRadius = 0.1 * min(locationMap.bounds.width, locationMap.bounds.height)
        dataSource?.locationData(locationView: locationMap)
        
    }

}
