//
//  WikiInfoManager.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 16/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WikiInfoManager {
    
    static let baseLink = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exlimit=max&explaintext&exintro&redirects=&titles="
    
    static func getArticleText(articleURL: URL, completion: @escaping ((String?) -> Void)) {
        
        let stringURL = articleURL.absoluteString
        if let articleName = stringURL.components(separatedBy: "/").last {
            debugPrint(baseLink + articleName)
            Alamofire.request(baseLink + articleName).responseData() { response in
                if let data = response.result.value {
                    
                    let json = JSON(data)
                    
                    let page = json.dictionaryValue["query"]!["pages"]
                    if page.count == 1 {
                        for (_, value) in page.dictionaryValue {
                            completion(value.dictionaryValue["extract"]!.stringValue)
                        }
                    }
                }
            }
        }
    }
    
    
}
