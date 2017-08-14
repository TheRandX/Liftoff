//
//  LaunchesManager.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 13/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum LaunchResponseParams: String {
    
    case Offset = "offset"
    case Count = "count"
    case Total = "total"
    
    case Id = "id"
    case Name = "name"
    case Date = "net"
    case TbdDate = "tbddate"
    case TbdTime = "tbdtime"
    case Status = "status"
    case WsStamp = "wsstamp"
    case WeStamp = "westamp"
    case DateStamp = "netstamp"
    case InforURLs = "infoURLs"
    case VidURLs = "vidURLs"
    case Holdreason = "holdreason"
    case Failreason = "failreason"
    case Probability = "probability"
    case Hashtag = "hashtag"
    
    case Location = "location"
    case Rocket = "rocket"
    case Missions = "missions"
    // This might be the most retarded way i've spent my time
}

// This class manages sending and recieving data from the launchlibrary API
class LaunchManager {
    
    private static let baseURL = "https://launchlibrary.net/1.2/launch"
    
    static func getLaunches(mode: String, options: [String: String]?, completion: @escaping ([Launch]?) -> Void) {
        
        var launches: [Launch]?
        
        // Construct the url from the options dictionary
        var url = LaunchManager.baseURL
        url.append("?")
        url.append("mode=\(mode)")
        if let options = options, !options.isEmpty {
            for (parameter, value) in options {
                url.append("\(parameter)=\(value)")
            }
        }
        // Create a request
        Alamofire.request(url).responseData() { response in
            
            if let data = response.result.value {
                
                launches = [Launch]()
                
                let json = JSON(data)
                // TODO: Add type request selection here
                for launch in json["launches"].arrayValue {
                    
                    let launchDict = launch.dictionaryValue
                    
                    // Recover the JSON array as an array of strings, then map it to URLs
                    let infoURLs = (launchDict[LaunchResponseParams.InforURLs.rawValue]?.arrayObject as? [String])?.map() { url in
                        return URL(fileURLWithPath: url)
                    }
                    
                    let videoURLs = (launchDict[LaunchResponseParams.VidURLs.rawValue]?.arrayObject as? [String])?.map() { url
                        in
                        return URL(fileURLWithPath: url)
                    }
                    
                    // Checks if date and time is known, if yes sets it
                    let tbdDate = (launchDict[LaunchResponseParams.TbdDate.rawValue]?.intValue)!
                    let tbdTime = (launchDict[LaunchResponseParams.TbdTime.rawValue]?.intValue)!
                    
                    var date: Date?, windowStart: Date?, windowEnd: Date? = nil
                    if !(tbdDate == 1 || tbdTime == 1) {
                        date = Date(timeIntervalSince1970: Double((launchDict[LaunchResponseParams.DateStamp.rawValue]?.intValue)!))
                        
                        windowStart = Date(timeIntervalSince1970:
                            Double((launchDict[LaunchResponseParams.WsStamp.rawValue]?.intValue)!))
                        
                        windowEnd = Date(timeIntervalSince1970:
                            Double((launchDict[LaunchResponseParams.WeStamp.rawValue]?.intValue)!))
                        
                    }
                    
                    // Splits the rocket name and mission name, rocket name on index 0, mission name on index 1
                    // ASSUMES THE SEPARATOR IS |
                    let nameComponents = (launchDict[LaunchResponseParams.Name.rawValue]?.stringValue)!.components(separatedBy: "|")
                    
                    var holdreason: String? = nil
                    if !(launchDict[LaunchResponseParams.Holdreason.rawValue]?.stringValue)!.isEmpty {
                        holdreason = (launchDict[LaunchResponseParams.Holdreason.rawValue]?.stringValue)!
                    }
                    var failreason: String? = nil
                    if !(launchDict[LaunchResponseParams.Failreason.rawValue]?.stringValue)!.isEmpty {
                        failreason = (launchDict[LaunchResponseParams.Failreason.rawValue]?.stringValue)!
                    }
                    
                    // If probability is -1 we should set it to nil for consistency
                    var probability: Int? = nil
                    if (launchDict[LaunchResponseParams.Probability.rawValue]?.intValue)! != -1 {
                        probability = (launchDict[LaunchResponseParams.Probability.rawValue]?.intValue)!
                    }
                    
                    // Create the launch object and append it to the launch array
                    launches?.append(Launch(id: (launchDict[LaunchResponseParams.Id.rawValue]?.intValue)!,
                                            rocketName: nameComponents[0],
                                            missionName: nameComponents[1],
                                            tbddate: tbdDate, tbdtime: tbdTime,
                                            date: date,
                                            status: (launchDict[LaunchResponseParams.Status.rawValue]?.intValue)!,
                                            windowstart: windowStart,
                                            windowend: windowEnd,
                                            infoURLs: infoURLs, vidURLs: videoURLs,
                                            holdreason: holdreason,
                                            failreason: failreason,
                                            probability: probability))
                }
                // Launches the completion handler
                completion(launches)
            }
        }
    }
    
}
