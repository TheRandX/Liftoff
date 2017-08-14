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
    
    case ID = "id"
    
    case Name = "name"
    case Description = "description"
    
    case Date = "net"
    case TbdDate = "tbddate"
    case TbdTime = "tbdtime"
    case Status = "status"
    case WsStamp = "wsstamp"
    case WeStamp = "westamp"
    case DateStamp = "netstamp"
    
    case WikiURL = "wikiURL"
    case InfoURLs = "infoURLs"
    case VidURLs = "vidURLs"
    
    case ImageURL = "imageURL"
    case ImageSizes = "imageSizes"
    
    case Holdreason = "holdreason"
    case Failreason = "failreason"
    case Probability = "probability"
    case Hashtag = "hashtag"
    
    case CountryCode = "countrycode"
    case Pads = "defaultPads"
    case Launch = "launch"
    case ObjectType = "type"
    case ObjectTypeName = "typeName"
    
    case Location = "location"
    case Rocket = "rocket"
    case Missions = "missions"
    case RocketFamily = "family"
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
                    
                    // Retrieve the location, rocket and mission objects
                    var location: Location? = nil
                    var rocket: Rocket? = nil
                    var missions: [Mission]? = nil
                    var pads: [Pad]? = nil
                    
                    // Retrieving location object
                    /*if let locDict = launchDict[LaunchResponseParams.Location.rawValue]?.dictionaryValue {
                     
                     let wikiURL = URL(fileURLWithPath: (locDict[LaunchResponseParams.WikiURL.rawValue]?.stringValue)!)
                     
                     location = Location(id: (locDict[LaunchResponseParams.ID.rawValue]?.intValue)!,
                     name: (locDict[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                     countrycode: (locDict[LaunchResponseParams.CountryCode.rawValue]?.stringValue)!,
                     wikiURL: wikiURL, infoURLs: URLArrayFromDictionary(locDict, arrayName: .InfoURLs))
                     }*/
                    
                    if let padDict = launchDict[LaunchResponseParams.Location.rawValue]?.dictionaryValue {
                        
                        print(padDict)
                    }
                    
                    // Retrieving rocket object
                    if let rocketDict = launchDict[LaunchResponseParams.Rocket.rawValue]?.dictionaryValue {
                        
                        let imageSizes = rocketDict[LaunchResponseParams.ImageSizes.rawValue]?.arrayValue.map() {
                            return $0.intValue
                        }
                        
                        var family: RocketFamily? = nil
                        if let familyDict = rocketDict[LaunchResponseParams.RocketFamily.rawValue]?.dictionaryValue {
                            // TODO: Implement code to fill out agency array
                            family = RocketFamily(id: (familyDict[LaunchResponseParams.ID.rawValue]?.intValue)!,
                                                  name: (familyDict[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                                                  agencies: nil)
                        }
                        
                        
                        rocket = Rocket(id: (rocketDict[LaunchResponseParams.ID.rawValue]?.intValue)!,
                                        name: (rocketDict[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                                        wikiURL: URLFromDictionary(rocketDict, URLName: .WikiURL)!,
                                        infoURLs: URLArrayFromDictionary(rocketDict, arrayName: .InfoURLs),
                                        imageURL: URLFromDictionary(rocketDict, URLName: .ImageURL),
                                        imageSizes: imageSizes, family: family)
                    }
                    
                    if let missionArray = launchDict[LaunchResponseParams.Missions.rawValue]?.arrayValue {
                        
                        let mappedMissions = missionArray.map() { mission -> Mission in
                            
                            let missionDict = mission.dictionaryValue
                            
                            // TODO: Implement code to fill out agencies and events arrays
                            return Mission(id: missionDict[LaunchResponseParams.ID.rawValue]!.intValue,
                                           name: missionDict[LaunchResponseParams.Name.rawValue]!.stringValue,
                                           description: missionDict[LaunchResponseParams.Description.rawValue]!.stringValue,
                                           typeName: missionDict[LaunchResponseParams.ObjectTypeName.rawValue]!.stringValue,
                                           wikiURL: URLFromDictionary(missionDict, URLName: .WikiURL),
                                           infoURLs: URLArrayFromDictionary(missionDict, arrayName: .InfoURLs))
                            
                        }
                        
                        missions = mappedMissions
                    }
                    
                    // Create the launch object and append it to the launch array
                    launches?.append(Launch(id: (launchDict[LaunchResponseParams.ID.rawValue]?.intValue)!,
                                            rocketName: nameComponents[0],
                                            missionName: nameComponents[1],
                                            tbddate: tbdDate, tbdtime: tbdTime,
                                            date: date,
                                            status: (launchDict[LaunchResponseParams.Status.rawValue]?.intValue)!,
                                            windowstart: windowStart,
                                            windowend: windowEnd,
                                            infoURLs: URLArrayFromDictionary(launchDict, arrayName: .InfoURLs),
                                            vidURLs: URLArrayFromDictionary(launchDict, arrayName: .VidURLs),
                                            holdreason: holdreason,
                                            failreason: failreason,
                                            probability: probability,
                                            launchEvent: nil,
                                            launchStatus: nil,
                                            location: nil,
                                            rocket: rocket,
                                            missions: missions))
                }
                // Launches the completion handler
                completion(launches)
            }
        }
    }
    
    // Returns optional URL from a JSON dictionary
    private static func URLFromDictionary(_ dictionary: [String: JSON], URLName: LaunchResponseParams) -> URL? {
        if let stringURL = dictionary[URLName.rawValue]?.stringValue {
            return URL(fileURLWithPath: stringURL)
        } else {
            return nil
        }
    }
    
    // Returns optional URL array from the JSON dictionary
    private static func URLArrayFromDictionary(_ dictionary: [String: JSON], arrayName: LaunchResponseParams) -> [URL]? {
        
        return (dictionary[arrayName.rawValue]?.arrayObject as? [String])?.map() { url in
            return URL(fileURLWithPath: url)
        }
        
    }
    
}
