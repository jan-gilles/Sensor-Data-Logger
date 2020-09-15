//
//  SensorData.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 12.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import Foundation

struct SensorData: Codable {
    
    let time: Date
    let batteryLevel: Double
    let location: Location?
    
    //Pitch, roll and yaw in radians ralative to a referance frame where the z-Axis is vertical and the x-Axis points toward true north
    let deviceOrientation: Orientation
    
    //Acceleration Data in g (9.81 m/s^2)
    let acceleration: Acceleration
    let userAcceleration: Acceleration
    
    //Rotation rate in radians per second
    let gyro: RotationRate
    
    //Magnetic field in microteslas
    let magneticField: MagneticField
    let adjustedMagneticField:  MagneticField
    
    //Pressure in kilopascals
    let pressure: Double
    
    let pedometer: Pedometer?
    
    enum CodingKeys: String, CodingKey {
        
        case time = "time"
        case batteryLevel = "battery_level"
        case location = "location"
        
        case deviceOrientation = "device_orientation"
        
        case acceleration = "acceleration"
        case userAcceleration = "user_acceleration"
        
        case gyro = "gyro"
        
        case magneticField = "magnatic_field"
        case adjustedMagneticField = "adjusted_magnetic_field"
        
        case pressure = "pressure"
        
        case pedometer = "pedometer"
        
    }
    
}
