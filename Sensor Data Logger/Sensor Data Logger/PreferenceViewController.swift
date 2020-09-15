//
//  PreferenceViewController.swift
//  Sensor Data Logger
//
//  Created by Jan Gilles on 14.08.20.
//  Copyright © 2020 Jan Gilles. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var dataIntervalTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.text = UserDefaults.standard.url(forKey: "serverURL")?.absoluteString ?? ""
        urlTextField.delegate = self
        
        let dataInterval = UserDefaults.standard.integer(forKey: "dataInterval")
        
        if dataInterval > 0 {
            dataIntervalTextField.text = String(dataInterval)
        }
        
        
        dataIntervalTextField.delegate = self
    }
    
}


extension PreferenceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == urlTextField {
            guard let str = textField.text,
                let url = URL(string: str) else {
                
                urlTextField.textColor = .red
                return false
            }
            
            urlTextField.textColor = .black
            
            UserDefaults.standard.set(url, forKey: "serverURL")
        }
        
        if textField == dataIntervalTextField {
            
            if let text = textField.text,
                let interval = Int(text) {
                
                UserDefaults.standard.set(interval, forKey: "dataInterval")
                NotificationCenter.default.post(name: .uploadIntervalChanged, object: nil)
                dataIntervalTextField.textColor = .black
            } else {
                dataIntervalTextField.textColor = .red
                
                return false
            }
            
        }
        
        textField.resignFirstResponder()
        return true
    }
    
}
