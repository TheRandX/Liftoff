//
//  SegmentedDataSource.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 19/12/2018.
//  Copyright © 2018 Pavol Margitfalvi. All rights reserved.
//

import UIKit
import MapKit

protocol SegmentedDataSource: class {
    
    func missionData(missionType: UILabel!, missionDescription: UILabel!)
    func rocketData(rocketInfo: UILabel!, rocketImage: UIImageView!)
    func locationData(locationView: MKMapView!)
    
}
