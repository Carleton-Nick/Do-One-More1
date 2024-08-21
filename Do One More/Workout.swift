//
//  Workout.swift
//  Do One More
//
//  Created by Nick Carleton on 6/26/24.
//

import Foundation

struct Workout: Hashable, Codable {
    var exerciseType: String
    var sets: [SetRecord]
}
