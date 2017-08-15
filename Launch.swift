//
//  Launch.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 12/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import Foundation



struct Agency {
    
    let id: Int
    
    let name, abbreviaton: String
    
    let type: Int
    let countryCode: String
    
    let wikiURL: URL?
    let infoURLs: [URL]?
}

struct ObjectType {
    
    let id: Int
    let name: String
}

struct Event {
    
    let id, parentID: Int
    
    let name, description: String
    let type, duration, relativeTime: Int
    
}

struct Launch {
    
    let id: Int
    let rocketName, missionName: String
    
    // Date related, if tbddate or tbdtime = 1, the date value isnt accurate
    let tbddate, tbdtime: Int
    let date: Date
    
    // Status of the mission, 1 Green, 2 Red, 3 Success, 4 Failed
    let status: Int
    
    // Start and end of launch window
    let windowstart, windowend: Date
    
    // Arrays containing URLs
    let infoURLs, vidURLs: [URL]?
    
    let holdreason, failreason: String?
    
    // -1 if unknown
    let probability: Int?
    
    // Objects
    let launchEvent: Event?
    let launchStatus: LaunchStatus?
    
    let location: Location?
    let rocket: Rocket?
    let missions: [Mission]?
}

struct LaunchStatus {
    
    let id: Int
    let name, description: String
}

struct Location {
    
    let id: Int
    
    let name, countrycode: String
    
    let wikiURL: URL?
    let infoURLs: [URL]?
    
    // Objects
    let pads: [Pad]?
}

struct Mission {
    
    let id: Int
    
    let name, description, typeName: String
    
    let wikiURL: URL?
    let infoURLs: [URL]?
}

struct Pad {
    
    let id: Int
    
    let name: String
    
    let latitude, longitude: Double
    let mapURL: URL?
    
    let wikiURL: URL?
    let infoURLs: [URL]?
    
    // Objects
    let agencies: [Agency]?
}

struct Rocket {
    
    let id: Int
    
    let name: String
    
    let wikiURL: URL?
    let infoURLs: [URL]?
    
    let imageURL: URL?
    let imageSizes: [Int]?
    
    // Objects
    let family: RocketFamily?
}

struct RocketFamily {
    
    let id: Int
    
    let name: String
    
    // Objects
    let agencies: [Agency]?
}

