//
//  SetRecord.swift
//  Do One More
//
//  Created by Nick Carleton on 8/15/24.
//

import Foundation

struct SetRecord: Hashable, Codable {
    var weight: String?
    var reps: Int?
    var metrics: Metrics? // Ensure this is included
}

struct Metrics: Hashable, Codable {
    var elapsedTime: String
    var distance: String
    var calories: String
    var custom: String
}
