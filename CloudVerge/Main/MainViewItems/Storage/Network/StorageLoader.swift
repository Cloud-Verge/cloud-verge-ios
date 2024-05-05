//
//  StorageLoader.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 06.05.2024.
//

import Foundation

protocol StorageLoaderProtocol {
    
    func uploadFile(from url: URL)
    
    func downloadFile()
}
