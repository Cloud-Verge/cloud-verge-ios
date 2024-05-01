//
//  NetworkService.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 01.05.2024.
//

import Foundation

enum NetworkService {
    
    static func sendAuthData(endpoint: String, email: String, password: String, completion: @escaping (Bool, String?) -> ()) {
        let url = URL(string: "http://0.0.0.0:8000/auth/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(false, nil)
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let responseJSON = responseJSON, let status = responseJSON["status"] as? String else {
                print("Invalid response")
                completion(false, nil)
                return
            }
            
            if status == "ok" {
                if endpoint == "register" {
                    completion(true, nil)
                    print("Registration successful")
                } else {
                    guard let token = responseJSON["token"] as? String else {
                        completion(false, nil)
                        print("Login failed")
                        return
                    }
                    completion(true, token)
                    print("Login successful")
                }
            } else {
                print("Registration failed with status: \(status)")
            }
        }
        
        task.resume()
    }
}
