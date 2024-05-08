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
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                let files = result.map({ FileModel(id: $0["file_id"] as! String, name: $0["filename"] as! String) })
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
            "Authorization": "Bearer \(token)"
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
    }
    
    static func getDownloadLink(token: String, fileID: String, onCompletion: @escaping (Result<String, Error>) -> ()) {
        let urlString = "http://0.0.0.0:8000/files/download_link/\(fileID)"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        AF.request(urlString, method: .get, parameters: [:], encoding: URLEncoding.queryString, headers: headers)
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
    }
    
    static func uploadFile(token: String, remotePath: String, localURL: URL, onCompletion: @escaping (Result<String, Error>) -> ()) {
        let remoteURL = URL(string: remotePath.replacingOccurrences(of: "localhost", with: "0.0.0.0"))!
        
        var request = URLRequest(url: remoteURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        let fileData = try? Data(contentsOf: localURL)
        let fileName = localURL.lastPathComponent
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData ?? Data())
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let uploadTask = URLSession.shared.uploadTask(with: request, from: nil) { data, response, error in
            if let error = error {
                onCompletion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                onCompletion(.failure(NSError(domain: "Invalid response", code: 400)))
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                onCompletion(.failure(NSError(domain: "Invalid response data", code: 402)))
                return
            }
            
            onCompletion(.success(responseString))
        }
        
        uploadTask.resume()
    }
    
    static func downloadFile(remotePath: String, token: String, completion: (Result<String, Error>) -> ()) {
        let downloadURL = URL(string: remotePath.replacingOccurrences(of: "localhost", with: "0.0.0.0"))!
        
        var request = URLRequest(url: downloadURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let downloadTask = URLSession.shared.downloadTask(with: request) { (localURL, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid response", code: 403)))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(NSError(domain: "No local URL received", code: 403)))
                return
            }
            
            let fileManager = FileManager.default
            guard let downloadsURL = try? fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
                completion(.failure(NSError(domain: "Error getting downloads directory", code: 403)))
                return
            }
            
            let destinationURL: URL
            if let disposition = httpResponse.value(forHTTPHeaderField: "Content-Disposition"), disposition.contains("filename=") {
                let filenameStart = disposition.range(of: "filename=")?.upperBound
                let filename = disposition[filenameStart!...].replacingOccurrences(of: "\"", with: "")
                destinationURL = downloadsURL.appendingPathComponent(filename)
            } else {
                destinationURL = downloadsURL.appendingPathComponent("\(UUID().uuidString).bin")
            }
            
            do {
                try fileManager.copyItem(at: localURL, to: destinationURL)
                completion(.success("File downloaded and saved to \(destinationURL.path)"))
            } catch {
                completion(.failure(NSError(domain: "Error saving file: \(error.localizedDescription)", code: 403)))
            }
        }
        
        downloadTask.resume()
    }
}
