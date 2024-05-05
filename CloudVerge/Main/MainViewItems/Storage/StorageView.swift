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
    
    var files: [FileModel] = []
    
    var body: some View {
        ZStack {
            List {
                ForEach(files) { file in
                    Text(file.name)
                }
            }
            VStack {
                Spacer()
                
                if let selectedFile = selectedFile {
                    Text("Selected file: \(selectedFile.lastPathComponent)")
                        .padding(16)
                    
                    ActionButton(text: "Upload to storage", buttonStyle: .secondary) {
                        print("load file")
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
        .preferredColorScheme(.light)
    }
}

#Preview {
    StorageView(files: [FileModel(name: "test1.txt"), FileModel(name: "test2.json")])
}
