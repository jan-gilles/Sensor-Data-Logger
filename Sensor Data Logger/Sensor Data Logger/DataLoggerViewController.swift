//
//  DataLoggerViewController.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 12.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation


class DataLoggerViewController: UIViewController {
    
    @IBOutlet weak var toggleDataButton: UIButton!
    @IBOutlet weak var dataFrequencyTextField: UITextField!
    
    @IBOutlet var accerlerationLabels: [UILabel]!
    @IBOutlet var userAccelerationLabels: [UILabel]!
    @IBOutlet var gyroLabels: [UILabel]!
    @IBOutlet var orientationLabels: [UILabel]!
    @IBOutlet var magneticFieldLables: [UILabel]!
    @IBOutlet var adjustedMagneticFieldLabels: [UILabel]!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet var locationLabels: [UILabel]!
    @IBOutlet var pedometerLabels: [UILabel]!
    
    var isGatheringData = false
    
    let sensorController = SensorController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensorController.setup(delegate: self)
        
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(errorAlertReceived(_:)), name: .errorAlert, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateUI() {
        
        dataFrequencyTextField.delegate = self
        
        toggleDataButton.backgroundColor = .white
        toggleDataButton.layer.cornerRadius = toggleDataButton.frame.size.width / 2
        
        toggleDataButton.layer.shadowColor = UIColor.black.cgColor
        toggleDataButton.layer.shadowRadius = 5.0
        toggleDataButton.layer.shadowOpacity = 0.5
        toggleDataButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    
    // MARK: - Toggle Data
    
    @IBAction func toggleData(_ sender: UIButton) {
        
        if isGatheringData {
            //Stop collecting sensor data
            sensorController.stopDataCollection()
            
            //update ui
            dataFrequencyTextField.isEnabled = true
            toggleDataButton.setTitle("Start", for: .normal)
            
        } else {
            //Get Frequency of data collection
            guard let dataFrequencyString = dataFrequencyTextField.text else { return }
            let frequency = Double(dataFrequencyString) ?? 1.0
            
            //Start collecting sensor data
            sensorController.startDataCollection(frequency: frequency)
            
            //update ui
            dataFrequencyTextField.isEnabled = false
            toggleDataButton.setTitle("Stop", for: .normal)
        }
        
        
        isGatheringData.toggle()
        
    }
    
}


// MARK: - Sensor Controller Delegate

extension DataLoggerViewController: SensorControllerDelegate {
    
    func sensorDataDidUpdate(_ sensorData: SensorData) {
        
        //set UI to gathered Data
        //very ugly code look away
        for accerlerationLabel in accerlerationLabels {
            
            switch accerlerationLabel.tag {
            case 0:
                accerlerationLabel.text = "x: \(String(format: "%.3f", sensorData.acceleration.x)) g"
            case 1:
                accerlerationLabel.text = "y: \(String(format: "%.3f", sensorData.acceleration.y)) g"
            case 2:
                accerlerationLabel.text = "z: \(String(format: "%.3f", sensorData.acceleration.z)) g"
            default:
                break
            }
        }
        
        for userAccerlerationLabel in userAccelerationLabels {
            
            switch userAccerlerationLabel.tag {
            case 0:
                userAccerlerationLabel.text = "x: \(String(format: "%.3f", sensorData.userAcceleration.x)) g"
            case 1:
                userAccerlerationLabel.text = "y: \(String(format: "%.3f", sensorData.userAcceleration.y)) g"
            case 2:
                userAccerlerationLabel.text = "z: \(String(format: "%.3f", sensorData.userAcceleration.z)) g"
            default:
                break
            }
        }
        
        for gyroLabel in gyroLabels {
            
            switch gyroLabel.tag {
            case 0:
                gyroLabel.text = "x: \(String(format: "%.2f", sensorData.gyro.x)) rad/s"
            case 1:
                gyroLabel.text = "y: \(String(format: "%.2f", sensorData.gyro.y)) rad/s"
            case 2:
                gyroLabel.text = "z: \(String(format: "%.2f", sensorData.gyro.z)) rad/s"
            default:
                break
            }
        }
        
        for orientationLabel in orientationLabels {
            
            switch orientationLabel.tag {
            case 0:
                orientationLabel.text = "pitch: \(String(format: "%.2f", sensorData.deviceOrientation.pitch)) rad"
            case 1:
                orientationLabel.text = "roll: \(String(format: "%.2f", sensorData.deviceOrientation.roll)) rad"
            case 2:
                orientationLabel.text = "yaw: \(String(format: "%.2f", sensorData.deviceOrientation.yaw)) rad"
            default:
                break
            }
            
        }
        
        for magneticFieldLabel in magneticFieldLables {
            
            switch magneticFieldLabel.tag {
            case 0:
                magneticFieldLabel.text = "x: \(String(format: "%.3f", sensorData.magneticField.x)) µT"
            case 1:
                magneticFieldLabel.text = "y: \(String(format: "%.3f", sensorData.magneticField.y)) µT"
            case 2:
                magneticFieldLabel.text = "z: \(String(format: "%.3f", sensorData.magneticField.z)) µT"
            default:
                break
            }
        }
        
        
        for adjustedMagneticFieldLabel in adjustedMagneticFieldLabels {
            
            switch adjustedMagneticFieldLabel.tag {
            case 0:
                adjustedMagneticFieldLabel.text = "x: \(String(format: "%.3f", sensorData.adjustedMagneticField.x)) µT"
            case 1:
                adjustedMagneticFieldLabel.text = "y: \(String(format: "%.3f", sensorData.adjustedMagneticField.y)) µT"
            case 2:
                adjustedMagneticFieldLabel.text = "y: \(String(format: "%.3f", sensorData.adjustedMagneticField.z)) µT"
            default:
                break
            }
            
        }
        
        pressureLabel.text = "\(String(format: "%.3f", sensorData.pressure)) kPa"
        
        
        for locationLabel in locationLabels {
            
            switch locationLabel.tag {
            case 0:
                locationLabel.text = "latitude: \(String(format: "%.3f", sensorData.location?.latitude ?? 0.0))°"
            case 1:
                locationLabel.text = "longitude: \(String(format: "%.3f", sensorData.location?.longitude ?? 0.0))°"
            default:
                break
            }
            
        }
        
        
        for pedometerLabel in pedometerLabels {
            
            switch pedometerLabel.tag {
            case 0:
                pedometerLabel.text = "steps: \(String(format: "%.0f", sensorData.pedometer?.numberOfSteps ?? 0.0))"
            case 1:
                pedometerLabel.text = "rate of steps: \(String(format: "%.3f", sensorData.pedometer?.rateOfSteps ?? 0.0)) steps/s"
            case 2:
                pedometerLabel.text = "pace: \(String(format: "%.3f", sensorData.pedometer?.pace ?? 0.0)) s/m"
            case 3:
                pedometerLabel.text = "approximate distance: \(String(format: "%.0f", sensorData.pedometer?.distance ?? 0.0)) m"
            default:
                break
            }
            
        }
        
    }
}


// MARK: - Error Alerts

extension DataLoggerViewController {
    
    @objc func errorAlertReceived(_ notification: Notification) {
        
        if let message = notification.userInfo?["message"] as? String {
            showErrorAlert(withMassege: message)
        } else {
            showErrorAlert(withMassege: "")
        }
    }
    
    func showErrorAlert(withMassege message: String) {
        
        let alert = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}


// MARK: - Text Field Delegate

extension DataLoggerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}
