//
//  Item.swift
//  FareLess
//
//  Created by Dmitriy Kharitonov on 13.07.2026.
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
