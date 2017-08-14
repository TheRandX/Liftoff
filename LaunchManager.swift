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
                    
                    launches?.append(launchObjectFromJSON(launchDict))
                    
                }
                // Launches the completion handler
                completion(launches)
            }
        }
    }
    
    
    // MARK: Retriever functions
    // Retrieves and completes the launch object
    private static func launchObjectFromJSON(_ dictionary: [String: JSON]) -> Launch {
        
        // Checks if date and time is known, if yes sets it
        let tbdDate = (dictionary[LaunchResponseParams.TbdDate.rawValue]?.intValue)!
        let tbdTime = (dictionary[LaunchResponseParams.TbdTime.rawValue]?.intValue)!
        
        var date: Date?, windowStart: Date?, windowEnd: Date? = nil
        if !(tbdDate == 1 || tbdTime == 1) {
            date = Date(timeIntervalSince1970: Double((dictionary[LaunchResponseParams.DateStamp.rawValue]?.intValue)!))
            
            windowStart = Date(timeIntervalSince1970:
                Double((dictionary[LaunchResponseParams.WsStamp.rawValue]?.intValue)!))
            
            windowEnd = Date(timeIntervalSince1970:
                Double((dictionary[LaunchResponseParams.WeStamp.rawValue]?.intValue)!))
            
        }
        
        // Splits the rocket name and mission name, rocket name on index 0, mission name on index 1
        // ASSUMES THE SEPARATOR IS |
        let nameComponents = (dictionary[LaunchResponseParams.Name.rawValue]?.stringValue)!.components(separatedBy: "|")
        
        var holdreason: String? = nil
        if !(dictionary[LaunchResponseParams.Holdreason.rawValue]?.stringValue)!.isEmpty {
            holdreason = (dictionary[LaunchResponseParams.Holdreason.rawValue]?.stringValue)!
        }
        var failreason: String? = nil
        if !(dictionary[LaunchResponseParams.Failreason.rawValue]?.stringValue)!.isEmpty {
            failreason = (dictionary[LaunchResponseParams.Failreason.rawValue]?.stringValue)!
        }
        
        // If probability is -1 we should set it to nil for consistency
        var probability: Int? = nil
        if (dictionary[LaunchResponseParams.Probability.rawValue]?.intValue)! != -1 {
            probability = (dictionary[LaunchResponseParams.Probability.rawValue]?.intValue)!
        }
        
        // Retrieve the location, rocket and mission objects
        var location: Location? = nil
        var rocket: Rocket? = nil
        var missions: [Mission]? = nil
        
        // Retrieving location object
        if let locDict = dictionary[LaunchResponseParams.Location.rawValue]?.dictionaryValue {
            
            location = locationFromJSON(locDict)
        }
        
        // Retrieving rocket object
        if let rocketDict = dictionary[LaunchResponseParams.Rocket.rawValue]?.dictionaryValue {
            rocket = rocketFromJSON(rocketDict)
        }
        
        // Retrieving mission object
        if let missionArray = dictionary[LaunchResponseParams.Missions.rawValue]?.arrayValue {
            missions = missionsFromArray(missionArray)
        }
        
        // Create the launch object and append it to the launch array
        // TODO: Add pads array to object
        return Launch(id: (dictionary[LaunchResponseParams.ID.rawValue]?.intValue)!,
                                rocketName: nameComponents[0],
                                missionName: nameComponents[1],
                                tbddate: tbdDate, tbdtime: tbdTime,
                                date: date,
                                status: (dictionary[LaunchResponseParams.Status.rawValue]?.intValue)!,
                                windowstart: windowStart,
                                windowend: windowEnd,
                                infoURLs: URLArrayFromDictionary(dictionary, arrayName: .InfoURLs),
                                vidURLs: URLArrayFromDictionary(dictionary, arrayName: .VidURLs),
                                holdreason: holdreason,
                                failreason: failreason,
                                probability: probability,
                                launchEvent: nil,
                                launchStatus: nil,
                                location: location,
                                rocket: rocket,
                                missions: missions)
    }
    
    // Returns an array of agency objects from JSON data
    private static func agencyArrayFromJSON(_ array: [JSON]) -> [Agency]? {
        
        return array.map() { dict in
            let dictionary = dict.dictionaryValue

            return Agency(id: (dictionary[LaunchResponseParams.ID.rawValue]?.intValue)!,
                          name: (dictionary[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                          abbreviaton: (dictionary[LaunchResponseParams.Abbreviation.rawValue]?.stringValue)!,
                          type: (dictionary[LaunchResponseParams.ObjectType.rawValue]?.intValue)!,
                          countryCode: (dictionary[LaunchResponseParams.CountryCode.rawValue]?.stringValue)!,
                          wikiURL: URLFromDictionary(dictionary, URLName: .WikiURL),
                          infoURLs: URLArrayFromDictionary(dictionary, arrayName: .InfoURLs))
        }
        
    }
    
    // Retrieves an object type from JSON data
    private static func objectTypeFromJSON(_ dictionary: [String: JSON]) -> ObjectType? {
        return ObjectType(id: dictionary[LaunchResponseParams.ID.rawValue]!.intValue,
                          name: dictionary[LaunchResponseParams.Name.rawValue]!.stringValue)
    }
    
    // Retrieves a mission array from JSON data
    private static func missionsFromArray(_ array: [JSON]) -> [Mission]? {
        
        return array.map() { mission -> Mission in
            
            let missionDict = mission.dictionaryValue
            
            // TODO: Implement code to fill out agencies and events arrays
            return Mission(id: missionDict[LaunchResponseParams.ID.rawValue]!.intValue,
                           name: missionDict[LaunchResponseParams.Name.rawValue]!.stringValue,
                           description: missionDict[LaunchResponseParams.Description.rawValue]!.stringValue,
                           typeName: missionDict[LaunchResponseParams.ObjectTypeName.rawValue]!.stringValue,
                           wikiURL: URLFromDictionary(missionDict, URLName: .WikiURL),
                           infoURLs: URLArrayFromDictionary(missionDict, arrayName: .InfoURLs))
            
        }
    }
    
    // Retrieves a location object from JSON data
    private static func locationFromJSON(_ dictionary: [String: JSON]) -> Location {
        return Location(id: (dictionary[LaunchResponseParams.ID.rawValue]?.intValue)!,
                            name: (dictionary[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                            countrycode: (dictionary[LaunchResponseParams.CountryCode.rawValue]?.stringValue)!,
                            wikiURL: URLFromDictionary(dictionary, URLName: .WikiURL),
                            infoURLs: URLArrayFromDictionary(dictionary, arrayName: .InfoURLs),
                            pads: padsArrayFromJSON((dictionary[LaunchResponseParams.Pads.rawValue]?.arrayValue)!))
    }
    
    private static func padsArrayFromJSON(_ array: [JSON]) -> [Pad]? {
        
        return array.map() { pad in
        let padDict = pad.dictionaryValue
            
            return Pad(id: (padDict[LaunchResponseParams.ID.rawValue]?.intValue)!,
                       name: (padDict[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                       latitude: (padDict[LaunchResponseParams.Latitude.rawValue]?.doubleValue)!,
                       longitude: (padDict[LaunchResponseParams.Longitude.rawValue]?.doubleValue)!,
                       mapURL: URLFromDictionary(padDict, URLName: .MapURL),
                       wikiURL: URLFromDictionary(padDict, URLName: .WikiURL),
                       infoURLs: URLArrayFromDictionary(padDict, arrayName: .InfoURLs),
                       agencies: agencyArrayFromJSON((padDict[LaunchResponseParams.Agencies.rawValue]?.arrayValue)!))
            
        }
        
    }
    
    // Retrieves an event object from JSON data
    private static func eventFromJSON(_ dictionary: [String: JSON], event: LaunchResponseParams) -> Event? {
        return Event(id: (dictionary[LaunchResponseParams.ID.rawValue]?.intValue)!,
                     parentID: (dictionary[LaunchResponseParams.ParentID.rawValue]?.intValue)!,
                     name: dictionary[LaunchResponseParams.Name.rawValue]!.stringValue,
                     description: (dictionary[LaunchResponseParams.Description.rawValue]?.stringValue)!,
                     type: dictionary[LaunchResponseParams.ObjectType.rawValue]!.intValue, duration: dictionary[LaunchResponseParams.Duration.rawValue]!.intValue,
                     relativeTime: dictionary[LaunchResponseParams.RelativeTime.rawValue]!.intValue)
    }
    
    // Retrieves a rocket object from JSON data
    private static func rocketFromJSON(_ dictionary: [String: JSON]) -> Rocket? {
        
        let imageSizes = dictionary[LaunchResponseParams.ImageSizes.rawValue]?.arrayValue.map() { return $0.intValue }
        
        var family: RocketFamily? = nil
        
        if let familyDict = dictionary[LaunchResponseParams.RocketFamily.rawValue]?.dictionaryValue {
            
            var agencies: [Agency]? = nil
            
            if let agencyDict = familyDict[LaunchResponseParams.Agencies.rawValue]?.arrayValue {
                agencies = agencyArrayFromJSON(agencyDict)
            }
            
            family = RocketFamily(id: (familyDict[LaunchResponseParams.ID.rawValue]?.intValue)!,
                                  name: (familyDict[LaunchResponseParams.Name.rawValue]?.stringValue)!,
                                  agencies: agencies)
        }
        
        return Rocket(id: (dictionary[LaunchResponseParams.ID.rawValue]?.intValue)!,
                      name: (dictionary[LaunchResponseParams.Name.rawValue]?.stringValue)!, wikiURL: URLFromDictionary(dictionary, URLName: .WikiURL), infoURLs: URLArrayFromDictionary(dictionary, arrayName: .InfoURLs),
                      imageURL: URLFromDictionary(dictionary, URLName: .ImageURL),
                      imageSizes: imageSizes, family: family)
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
