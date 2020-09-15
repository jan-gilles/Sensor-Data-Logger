//
//  ModelController.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 12.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import Foundation

class ModelController {
    
    func postData(_ sensorData: SensorDataSet) {
        
        //https://www.jan-gilles-software-development.de/other-stuff/SDL-Responder/save_sensor_data.php
        
        guard let url = UserDefaults.standard.url(forKey: "serverURL") else { return }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        
        let data: Data
        
        do {
            try data = encoder.encode(sensorData)
        } catch {
            data = Data()
            let error = error as NSError
            print("An error occured \(error), \(error.userInfo)")
            
            NotificationCenter.default.post(name: .errorAlert, object: nil, userInfo: [
                "message" : "The sensor data could not be properly encoded to JSON."
            ])
        }
        
        print(data)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error as NSError? {
                print("An error occured \(error), \(error.userInfo)")
                NotificationCenter.default.post(name: .errorAlert, object: nil, userInfo: [
                    "message" : "An error occured trying to communicate with the server"
                ])
            }
            
        }
        
        task.resume()
        
    }
    
}
