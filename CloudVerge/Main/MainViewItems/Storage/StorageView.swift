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
    
    private var interactor: StorageInteractorProtocol = StorageInteractor()
    
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
                        interactor.downloadFile(token: token, fileID: file.id, loadResult: $downloadResult)
                        self.showDownloadResult.toggle()
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
                        interactor.uploadFile(token: token, selectedFile: selectedFile)
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
            selectedFile = nil
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
