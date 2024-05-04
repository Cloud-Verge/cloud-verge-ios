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
            TabView {
                StorageView()
                    .tabItem {
                        Image(systemName: "folder.fill")
                        Text("Storage")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            }
            .navigationTitle("CloudVerge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainView()
}
