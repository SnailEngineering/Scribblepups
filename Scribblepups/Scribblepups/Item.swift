//
//  Item.swift
//  Scribblepups
//
//  Created by Kyle Andrews on 4/17/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
