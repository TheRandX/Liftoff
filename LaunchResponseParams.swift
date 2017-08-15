//
//  LaunchResponseParams.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 14/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import Foundation

enum LaunchResponseParams: String {
    
    case Offset = "offset"
    case Count = "count"
    case Total = "total"
    
    case ID = "id"
    case ParentID = "parentid"
    
    case Name = "name"
    case Description = "description"
    case Abbreviation = "abbrev"
    
    case Date = "net"
    case TbdDate = "tbddate"
    case TbdTime = "tbdtime"
    case Status = "status"
    
    case WsStamp = "wsstamp"
    case WeStamp = "westamp"
    case DateStamp = "netstamp"
    
    case StringDate = "isonet"
    
    case Duration = "duration"
    case RelativeTime = "relativeTime"
    
    case WikiURL = "wikiURL"
    case InfoURLs = "infoURLs"
    case VidURLs = "vidURLs"
    case MapURL = "mapURL"
    
    case Latitude = "latitude"
    case Longitude = "longitude"
    
    case ImageURL = "imageURL"
    case ImageSizes = "imageSizes"
    
    case Holdreason = "holdreason"
    case Failreason = "failreason"
    case Probability = "probability"
    case Hashtag = "hashtag"
    
    case CountryCode = "countryCode"
    case Pads = "pads"
    case ObjectType = "type"
    case ObjectTypeName = "typeName"
    
    case Location = "location"
    case Rocket = "rocket"
    case Missions = "missions"
    case RocketFamily = "family"
    case AgencyType = "agencyType"
    case EventType = "eventType"
    case Launch = "launch"
    case LaunchEvent = "launchEvent"
    case LaunchStatus = "launchStatus"
    case MissionEvent = "missionEvent"
    case MissionType = "missionType"
    case Pad = "pad"
    case Agencies = "agencies"
    
    // This might be the most retarded way i've spent my time
}
