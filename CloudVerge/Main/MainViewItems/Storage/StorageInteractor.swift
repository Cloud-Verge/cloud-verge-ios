//
//  StorageInteractor.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 08.05.2024.
//

import Foundation

protocol StorageInteractorProtocol {
    
    func uploadFile(token: String, selectedFile: URL)
    
    func downloadFile(token: String, fileID: String, loadResult: inout Bool)
    
    func getFilesList()
}

class StorageInteractor: StorageInteractorProtocol {
    
    func uploadFile(token: String, selectedFile: URL) {
        StorageNetworkService.getUploadLink(token: token, access: "PUBLIC") { result in
            switch result {
            case let .success(link):
                StorageNetworkService.uploadFile(token: token, remotePath: link, localURL: selectedFile) { result in
                    switch result {
                    case let .success(resp):
                        print(resp)
                    case let .failure(error):
                        print("Error uploading file to server: \(error.localizedDescription)")
                    }
                }
            case let .failure(error):
                print("Failed to get upload link: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadFile(token: String, fileID: String, loadResult: inout Bool) {
        StorageNetworkService.getDownloadLink(token: token, fileID: fileID) { result in
            switch result {
            case let .success(link):
                StorageNetworkService.downloadFile(remotePath: link, token: token) { result in
                    switch result {
                    case let .success(resp):
                        print(resp)
                        loadResult = true
                    case let .failure(error):
                        print("Error downloading file from server: \(error.localizedDescription)")
                        loadResult = false
                    }
                }
            case let .failure(error):
                print("Failed to get download link: \(error.localizedDescription)")
                loadResult = false
            }
        }
    }
    
    func getFilesList() {
        <#code#>
    }
    
    
}
