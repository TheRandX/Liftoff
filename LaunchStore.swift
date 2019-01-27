//
//  LaunchesStore.swift
//  Liftoff
//
//  Created by Pavol Margitfalvi on 12/08/2017.
//  Copyright © 2017 Pavol Margitfalvi. All rights reserved.
//

import Foundation

class LaunchStore {
    
    var items = [Launch]()
    
    var count: Int {
        return items.count
    }
    
    func clear() {
        items.removeAll()
    }
    
    func sortItems() {
        items.sort() { (launch1, launch2) in
            
            if launch1.date.timeIntervalSince1970 < launch2.date.timeIntervalSince1970 {
                return true
            } else {
                return false
            }
        }
    }
    
}
