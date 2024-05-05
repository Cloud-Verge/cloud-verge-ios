//
//  StorageView.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 03.05.2024.
//

import SwiftUI

struct StorageView: View {
    
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
                ActionButton(text: "Upload file", buttonStyle: .primary) {}
                    .padding(.bottom, 25)
            }
        }
    }
}

#Preview {
    StorageView(files: [FileModel(name: "test1.txt"), FileModel(name: "test2.json")])
}
