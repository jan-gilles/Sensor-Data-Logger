//
//  Pedometer.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 13.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import Foundation

struct Pedometer: Codable {
    
    let numberOfSteps: Int
    
    //measured in steps/s
    let rateOfSteps: Double
    
    //measured in s/m
    let pace: Double
    
    //measured in m
    let distance: Double
    
    enum CodingKeys: String, CodingKey {
        
        case numberOfSteps = "number_of_steps"
        case rateOfSteps = "rate_of_steps"
        case pace = "pace"
        case distance = "distance"
    }
}
