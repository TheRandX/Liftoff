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
}
