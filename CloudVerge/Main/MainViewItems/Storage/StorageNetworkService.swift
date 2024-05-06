//
//  StorageNetworkService.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 05.05.2024.
//

import Alamofire
import Foundation

enum StorageNetworkService {
    
    static func getFilesList(token: String, onCompletion: @escaping (Result<[FileModel], Error>) -> ()) {
        let url = URL(string: "http://0.0.0.0:8000/files/list")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                onCompletion(.failure(error!))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                guard let json = json else {
                    onCompletion(.failure(NSError(domain: "Invalid response data", code: 400)))
                    return
                }
                guard let status = json["status"] as? String, status == "ok" else {
                    onCompletion(.failure(NSError(domain: "AuthorizationError", code: 401)))
                    return
                }
                guard let result = json["result"] as? [[String: Any]] else {
                    onCompletion(.failure(NSError(domain: "Invalid files data", code: 402)))
                    return
                }
                let files = result.map({ FileModel(id: $0["id"] as! Int, name: $0["filename"] as! String) })
                onCompletion(.success(files))
            } catch let serializationError {
                onCompletion(.failure(serializationError))
            }
        }.resume()
    }
    
    static func getUploadLink(token: String, access: String, onCompletion: @escaping (Result<String, Error>) -> ()) {
        let urlString = "http://0.0.0.0:8000/files/upload_link"
        let param = ["access": access]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "OAuth \(token)"
        ]
        AF.request(urlString, method: .get, parameters: param, encoding: URLEncoding.queryString, headers: headers)
            .responseJSON { response in
                switch response.result {
                  case let .success(json):
                    print("Success with JSON: \(json)")
                    let dict = json as! NSDictionary
                    guard let url = dict.object(forKey: "url") as? String else {
                        onCompletion(.failure(NSError(domain: "Invalid response data", code: 400)))
                        return
                    }
                    onCompletion(.success(url))
                  case let .failure(error):
                    onCompletion(.failure(error))
                  }
            }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let requestBody = ["access": access]
//        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                onCompletion(.failure(error!))
//                return
//            }
//
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
//                guard let json = json else {
//                    onCompletion(.failure(NSError(domain: "Invalid response data", code: 400)))
//                    return
//                }
//                guard let status = json["status"] as? String, status == "ok" else {
//                    onCompletion(.failure(NSError(domain: "AuthorizationError", code: 401)))
//                    return
//                }
//                guard let result = json["url"] as? String else {
//                    onCompletion(.failure(NSError(domain: "Invalid url data", code: 402)))
//                    return
//                }
//                onCompletion(.success(result))
//            } catch let serializationError {
//                onCompletion(.failure(serializationError))
//            }
//        }.resume()
    }

    static func downloadFile(name: String, fileID: Int, token: String, completion: @escaping (Bool) -> ()) {
        let downloadURL = URL(string: "http://0.0.0.0/files/ask_download")!
        var request = URLRequest(url: downloadURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody = ["file_id": fileID]
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error uploading file: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server returned an error")
                completion(false)
                return
            }
            
            if let data = data {
                let downloadsPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0]
                let fileManager = FileManager.default
                let filePath = (downloadsPath as NSString).appendingPathComponent(name)
                
                do {
                    try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                    print("File saved at path: \(filePath)")
                    completion(true)
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
}
