//
//  ViewController.swift
//  API - POST
//
//  Created by ali on 09/09/2024.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    
    @IBOutlet weak var txtField: UITextView!
    
    @IBOutlet weak var jobTxtField: UITextField!
    
    @IBOutlet weak var nameTxtField: UITextField!
    
    @IBOutlet weak var sendDataBtn: UIButton!
    
    struct UserResponse: Codable {
        let createdAt: String
        let id: Int
        let job: String
        let name: String
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        

    }
    
    @IBAction func btnTapped(_ sender: Any) {
        sendingData { response in
            print("This is the actual response: \(response ?? "none found")")

            // Store the response in the UITextView
            if let responseData = response {
                // Convert response data to a string (assuming it's JSON)
                self.txtField.text = "\(responseData)"
                self.showAlert(with: "Data sent")
            } else {
                self.txtField.text = "No response found."
                self.showAlert(with: "Data was not sent")
            }
        }
    }
    
    
    func showAlert(with message: String) {
        let alertController = UIAlertController(title: "User Information", message: message, preferredStyle: .alert)
        
        // Add an action to dismiss the alert
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }

    struct DataToSend: Encodable {
        let name: String
        let job: String
    }

    var recievedResponse: Any?

    func sendingData(completion: @escaping (Any?) -> Void) {
        let endPoint = "https://reqres.in/api/user"
        let sendingData = DataToSend(name: nameTxtField.text ?? "nothing entered", job: jobTxtField.text ?? "nothing entered" )

        AF.request(
            endPoint,
            method: .post,
            parameters: sendingData,
            encoder: JSONParameterEncoder.default
        ).responseJSON { response in
            switch response.result {
            case .success(let data):
                // Save the response data
                self.recievedResponse = data
                completion(data) // Call the completion handler with the data
            case .failure(let error):
                print("Error: \(error)")
                completion(nil) // Call the completion handler with nil in case of error
            }
        }

        print("Function run")
    }

}


