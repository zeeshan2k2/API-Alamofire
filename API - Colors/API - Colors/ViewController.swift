//
//  ViewController.swift
//  API - Colors
//
//  Created by Zeeshan on 06/09/2024.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var colorTxtField: UITextField?
    
    @IBOutlet var findValOrNameBtn: UIButton?
    
    @IBOutlet var responseLbl: UILabel?
    
    @IBOutlet var colorView: UIView?
    
    struct Color: Codable {
        let id: Int
        let name: String
        let hex: String
    }
    
    
    let apiEndpoint = "https://api.sampleapis.com/csscolornames/colors"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorView?.layer.cornerRadius = 20
        colorView?.layer.borderWidth = 2
        colorView?.layer.borderColor = UIColor.black.cgColor
        
        // Add a tap gesture recognizer to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // Create a flexible space and Done button
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        // Add the flexible space and Done button to the toolbar
        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        // Assign the toolbar to the inputAccessoryView of the text field
        colorTxtField!.inputAccessoryView = toolbar

        // Set the text field delegate
        colorTxtField!.delegate = self
    }
    
    // Method that gets called when Done button is tapped
    @objc func doneTapped() {
        colorTxtField!.resignFirstResponder() // Dismiss the keyboard
    }
    
    // Method to dismiss the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func implementation() {
        var enteredVal = colorTxtField?.text?.lowercased()
        if ((enteredVal?.isEmpty) != nil) {
            responseLbl?.text = ""
        }
        
        if enteredVal?.first == "#" {
            isHexValuePresent(hexVal: enteredVal!) { [self] response in
                if response {
                    print("\(enteredVal!) is present in the API")
                    
                    print()
                    
                    // Example usage of getColorName(fromHex:)
                    self.getColorName(fromHex: enteredVal!) { colorName in
                        if let name = colorName {
                            print("The color name for hex value \(enteredVal!) is \(name)")
                            self.responseLbl?.text = "The color name for hex value \(enteredVal!) is \(name.capitalized)"
                            self.colorView!.backgroundColor = UIColor(hex: enteredVal!)
                        } else {
                            print("No color found for hex value \(enteredVal!)")
                            self.responseLbl?.text = "No color found for hex value \(enteredVal!)"
                        }
                    }
                } else {
                    print("hex value is not present in the API")
                    self.responseLbl?.text = "hex value is not present in the API"
                }
            }
        } else {
            isColorPresent(colorName: enteredVal!) { [self] response in
                if response {
                    print("\(enteredVal!) is present in the API")
    
                    print()
    
                    // Example usage of getHexValue(fromColorName:)
                    self.getHexValue(fromColorName: enteredVal!) { hexValue in
                        if let hex = hexValue {
                            print("The hex value for color name \(enteredVal!) is \(hex)")
                            self.responseLbl?.text = "The hex value for color name \(enteredVal!) is \(hex)"
                            self.colorView!.backgroundColor = UIColor(hex: hex)
                        } else {
                            print("No hex value found for color name \(enteredVal!)")
                            self.responseLbl?.text = "No hex value found for color name \(enteredVal!)"
                        }
                    }
                } else {
                    print("\(enteredVal!) is not present in the API")
                    self.responseLbl?.text = "\(enteredVal!) is not present in the API"
                }
            }
        }
    }
    
    
    @IBAction func findValOrNameBtnTapped(_ sender: Any) {
        implementation()
    }
    
    // to check the hex value is in the API
    func isHexValuePresent(hexVal: String, completion: @escaping (Bool) -> Void) {
        AF.request(apiEndpoint).responseDecodable(of: [Color].self) { response in
            switch response.result {
            case .success(let hex):
                var hexValues: [String] = []
                
                for value in hex {
                    let hexValueLower = value.hex.lowercased()
                    hexValues.append(hexValueLower)
                }
                
                let isPresent = hexValues.contains(hexVal)
                completion(isPresent)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    
    // to check whether the color is present in the API
    func isColorPresent(colorName: String, completion: @escaping (Bool) -> Void) {
        AF.request(apiEndpoint).responseDecodable(of: [Color].self) { response in
            switch response.result{
            case .success(let colors):
                var colorValues: [String] = []
                
                for color in colors {
                    let lowerColorName = color.name.lowercased()
                    colorValues.append(lowerColorName)
                }
                
                let isPresent = colorValues.contains(colorName)
                completion(isPresent)
            
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func getColorName(fromHex hexVal: String, completion: @escaping (String?) -> Void) {
        AF.request(apiEndpoint).responseDecodable(of: [Color].self) { response in
            switch response.result {
            case .success(let colors):
                // Convert the input hex value to lowercase
                let hexValLower = hexVal.lowercased()
                
                // Search for the color name associated with the hex value
                if let color = colors.first(where: { $0.hex.lowercased() == hexValLower }) {
                    completion(color.name)
                } else {
                    completion(nil) // No matching color found
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func getHexValue(fromColorName colorName: String, completion: @escaping (String?) -> Void) {
        AF.request(apiEndpoint).responseDecodable(of: [Color].self) { response in
            switch response.result {
            case .success(let colors):
                // Convert the input color name to lowercase
                let colorNameLower = colorName.lowercased()
                
                // Search for the hex value associated with the color name
                if let color = colors.first(where: { $0.name.lowercased() == colorNameLower }) {
                    completion(color.hex)
                } else {
                    completion(nil) // No matching color found
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    
}
