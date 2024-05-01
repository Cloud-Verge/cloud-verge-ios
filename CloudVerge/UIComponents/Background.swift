//
//  Background.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 01.05.2024.
//

import SwiftUI

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.9)
        .overlay(content)
    }
}
