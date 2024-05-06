//
//  StorageView.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 03.05.2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct StorageView: View {
    
    @State private var selectedFile: URL?
    @State private var isPickerShown = false
    @State private var token = UserDefaults.standard.value(forKey: "token") as? String ?? "None"
    
    @State private var showDownloadResult: Bool = false
    @State private var downloadResult = false
    
    @State var files: [FileModel] = []
    
    var body: some View {
        ZStack {
            List {
                ForEach(files) { file in
                    HStack {
                        Text(file.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .onTapGesture {
                        StorageNetworkService.downloadFile(name: file.name, fileID: file.id, token: token) { result in
                            showDownloadResult.toggle()
                            self.downloadResult = result
                        }
                    }
                    .alert(downloadResult ? "File loaded successfully" : "Flie load failed",
                           isPresented: $showDownloadResult) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
            VStack {
                Spacer()
                
                if let selectedFile = selectedFile {
                    Text("Selected file: \(selectedFile.lastPathComponent)")
                        .padding(16)
                    
                    ActionButton(text: "Upload to storage", buttonStyle: .secondary) {
                        StorageNetworkService.getUploadLink(token: token, access: "PUBLIC") { result in
                            switch result {
                            case let .success(link):
                                print(link)
                            case let .failure(error):
                                print("Failed to get upload link: \(error.localizedDescription)")
                            }
                        }
                    }
                    .padding(.bottom, 25)
                } else {
                    ActionButton(text: "Upload file", buttonStyle: .primary) {
                        isPickerShown = true
                    }
                    .padding(.bottom, 25)
                }
            }
            .fileImporter(isPresented: $isPickerShown, allowedContentTypes: [.data]) { result in
                switch result {
                case .success(let url):
                    selectedFile = url
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            StorageNetworkService.getFilesList(token: token) { result in
                switch result {
                case let .success(files):
                    self.files = files
                case let .failure(error):
                    self.files = []
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    StorageView()
}
