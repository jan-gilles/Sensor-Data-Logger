//
//  SensorController.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 13.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation


protocol SensorControllerDelegate: class {
    
    func sensorDataDidUpdate(_ sensorData: SensorData)
    
}

class SensorController: NSObject {
    
    weak var delegate: SensorControllerDelegate?
    
    var timer = Timer()
    
    let motion = CMMotionManager()
    
    let barometer = CMAltimeter()
    var latestPressureData: Double?
    
    let pedometer = CMPedometer()
    var latestPedometerMeasurement: Pedometer?
    
    let locationManager = CLLocationManager()
    var latestPosition: Location?
    
    let modelController = ModelController()
    
    var uploadInterval = 30.0
    var dataCyclesPerUpload = 1
    var dataCycleCounter = 0
    
    var sensorData: [SensorData] = []
    
    func setup(delegate: SensorControllerDelegate) {
        
        self.delegate = delegate
        
        uploadIntervalChanged()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(uploadIntervalChanged), name: .uploadIntervalChanged, object: nil)
    }
    
    @objc func uploadIntervalChanged() {
        
        let interval = UserDefaults.standard.integer(forKey: "dataInterval")
        
        if interval > 0 {
            self.uploadInterval = Double(interval)
        }
        
    }
    
    
    // MARK: - Start Collecting Data
    
    func startDataCollection(frequency: Double) {
        
        dataCyclesPerUpload = Int(ceil(uploadInterval * frequency))
        dataCycleCounter = 0
        
        if self.motion.isAccelerometerAvailable && self.motion.isGyroAvailable && self.motion.isMagnetometerAvailable && CMAltimeter.isRelativeAltitudeAvailable() {
            
            let updateInterval = 1 / frequency
            
            //set up sensors
            self.motion.deviceMotionUpdateInterval = updateInterval
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
            
            self.motion.accelerometerUpdateInterval = updateInterval
            self.motion.startAccelerometerUpdates()
            
            self.motion.gyroUpdateInterval = updateInterval
            self.motion.startGyroUpdates()
            
            self.motion.magnetometerUpdateInterval = updateInterval
            self.motion.startMagnetometerUpdates()
            
            self.barometer.startRelativeAltitudeUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                
                if let data = data {
                    self?.latestPressureData = data.pressure.doubleValue
                }
                
            }
            
            
            if CMPedometer.isPaceAvailable() && CMPedometer.isCadenceAvailable() && CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable() {
                
                self.pedometer.startUpdates(from: Date()) { [weak self] (data, error) in
                    
                    if let data = data {
                        
                        guard let rateOfSteps = data.currentCadence?.doubleValue,
                            let pace = data.currentPace?.doubleValue,
                            let distance = data.distance?.doubleValue else { return }
                        
                        self?.latestPedometerMeasurement = Pedometer(
                            numberOfSteps: data.numberOfSteps.intValue,
                            rateOfSteps: rateOfSteps,
                            pace: pace,
                            distance: distance
                        )
                    }
                }
                
            }
            
            
            
            self.timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(gatherData), userInfo: nil, repeats: true)
            
        } else {
            
            NotificationCenter.default.post(name: .errorAlert, object: nil, userInfo: [
                "message" : "Some Sensor appears to be unavailable!"
            ])
            
        }
        
    }
    
    // MARK: - Stop collecting data
    
    func stopDataCollection() {
        
        self.motion.stopDeviceMotionUpdates()
        self.motion.stopAccelerometerUpdates()
        self.motion.stopGyroUpdates()
        self.motion.stopMagnetometerUpdates()
        self.barometer.stopRelativeAltitudeUpdates()
        
        
        self.timer.invalidate()
    }
    
    
    // MARK: - Gather Data
    
    @objc func gatherData() {
        
        guard let accelerationData = self.motion.accelerometerData?.acceleration,
            let gyroData = self.motion.gyroData?.rotationRate,
            let magnetometerData = self.motion.magnetometerData?.magneticField,
            let barometerData = self.latestPressureData,
            let userAcceleration = self.motion.deviceMotion?.userAcceleration,
            let correctedMagneticField = self.motion.deviceMotion?.magneticField,
            let deviceOrientation = self.motion.deviceMotion?.attitude else { return }
        
        let newSensorData = SensorData(
            time: Date(),
            batteryLevel: Double(UIDevice.current.batteryLevel),
            location: self.latestPosition,
            deviceOrientation: Orientation(
                pitch: deviceOrientation.pitch,
                roll: deviceOrientation.roll,
                yaw: deviceOrientation.yaw
            ),
            acceleration: Acceleration(
                x: accelerationData.x,
                y: accelerationData.y,
                z: accelerationData.z
            ),
            userAcceleration: Acceleration(
                x: userAcceleration.x,
                y: userAcceleration.y,
                z: userAcceleration.z
            ),
            gyro: RotationRate(
                x: gyroData.x,
                y: gyroData.y,
                z: gyroData.z
            ),
            magneticField: MagneticField(
                x: magnetometerData.x,
                y: magnetometerData.y,
                z: magnetometerData.z
            ),
            adjustedMagneticField: MagneticField(
                x: correctedMagneticField.field.x,
                y: correctedMagneticField.field.y,
                z: correctedMagneticField.field.z
            ),
            pressure: barometerData,
            pedometer: self.latestPedometerMeasurement
        )
        
        delegate?.sensorDataDidUpdate(newSensorData)
        
        self.sensorData.append(newSensorData)
        
        dataCycleCounter += 1
        
        if dataCycleCounter >= dataCyclesPerUpload {
            
            //Send data to server
            let dataSet = SensorDataSet(sensorData: self.sensorData)
            self.modelController.postData(dataSet)
            
            self.sensorData.removeAll()
            dataCycleCounter = 0
            
        }
        
    }
    
}


// MARK: - Location Manager Delegate

extension SensorController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.latestPosition = Location(latitude: locationValue.latitude, longitude: locationValue.longitude)
    }
    
}
