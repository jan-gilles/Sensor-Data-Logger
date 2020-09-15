//
//  SensorDataSet.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 13.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import Foundation

struct SensorDataSet: Codable {
    
    let sensorData: [SensorData]
    
    enum CodingKeys: String, CodingKey {
        
        case sensorData = "sensor_data"
    }
}
