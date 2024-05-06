//
//  SettingsNetworkService.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 04.05.2024.
//

import Foundation

enum SettingsNetworkService {
    
    static func updatePassword(password: String, token: String, completion: @escaping (Bool) -> ()) {
        let url = URL(string: "http://0.0.0.0:8000/auth/update_password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let json: [String: Any] = [
            "new_password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let responseJSON = responseJSON, let status = responseJSON["status"] as? String else {
                print("Invalid response")
                completion(false)
                return
            }
            
            if status == "ok" {
                completion(true)
                print("Password updated successfuly")
            } else {
                print("Password update failed with status: \(status)")
            }
        }
        
        task.resume()
    }
}
