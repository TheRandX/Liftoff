//
//  Launch.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 12/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import Foundation

// TODO: Add representations for location, rocket and mission objects
struct Launch {
    
    let id: Int
    let rocketName, missionName: String
    
    // Date related, if tbddate or tbdtime = 1, the date value isnt accurate
    let tbddate, tbdtime: Int
    let date: Date?
    
    // Status of the mission, 1 Green, 2 Red, 3 Success, 4 Failed
    let status: Int
    
    // Start and end of launch window
    let windowstart, windowend: Date?
    
    // Arrays containing URLs
    let infoURLs, vidURLs: [URL]?
    
    let holdreason, failreason: String?
    
    // -1 if unknown
    let probability: Int?
}
