//
//  MainView.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 01.05.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            StorageView()
                .navigationTitle("CloudVerge")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
        }
    }
}

#Preview {
    MainView()
}
