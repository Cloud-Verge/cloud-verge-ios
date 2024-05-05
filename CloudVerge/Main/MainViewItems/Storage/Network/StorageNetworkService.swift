//
//  StorageNetworkService.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 05.05.2024.
//

import Foundation

enum StorageNetworkService {
    
    static func asyncGet(url: String, headers: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }
            
            var result: [String: Any] = [
                "status": httpResponse.statusCode,
                "content_type": httpResponse.allHeaderFields["Content-Type"] as? String ?? "",
                "text": String(data: data ?? Data(), encoding: .utf8) ?? "",
                "json": try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])
            ]
            completion(.success(result))
        }
        
        task.resume()
    }
    
    static func asyncPost(url: String, data: Data? = nil, headers: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }
            
            var result: [String: Any] = [
                "status": httpResponse.statusCode,
                "content_type": httpResponse.allHeaderFields["Content-Type"] as? String ?? "",
                "text": String(data: data ?? Data(), encoding: .utf8) ?? "",
                "json": try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])
            ]
            completion(.success(result))
        }
        
        task.resume()
    }
    
    static func asyncPut(url: String, data: Data? = nil, headers: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }
            
            var result: [String: Any] = [
                "status": httpResponse.statusCode,
                "content_type": httpResponse.allHeaderFields["Content-Type"] as? String ?? "",
                "text": String(data: data ?? Data(), encoding: .utf8) ?? "",
                "json": try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])
            ]
            completion(.success(result))
        }
        
        task.resume()
    }
    
    static func asyncUploadFile(url: String, path: String, headers: [String: String]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                guard let fileData = FileManager.default.contents(atPath: path) else {
                    throw NSError(domain: "File not found", code: 0, userInfo: nil)
                }

                let session = URLSession.shared
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "PUT"
                request.httpBody = fileData
                
                if let headers = headers {
                    for (key, value) in headers {
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                }

                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                        return
                    }

                    var result: [String: Any] = [
                        "status": httpResponse.statusCode,
                        "content_type": httpResponse.allHeaderFields["Content-Type"] as? String ?? "",
                        "text": String(data: data ?? Data(), encoding: .utf8) ?? "",
                        "json": try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])
                    ]
                    completion(.success(result))
                }

                task.resume()
            } catch {
                completion(.failure(error))
            }
        }
    }
}
