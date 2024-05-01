//
//  ActionButton.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 01.05.2024.
//

import SwiftUI

/// Стиль кнопки
enum ActionButtonStyle {
    /// Черный фон. белый текст
    case primary
    /// Белый фон, черный текст
    case secondary
}

struct ActionButton: View {
    
    var text: String
    var buttonStyle: ActionButtonStyle
    
    var action: () -> ()
    
    var body: some View {
        Button(text, action: action)
            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            .font(.system(size: 16))
            .foregroundStyle(getForegroundColor())
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(getBackgroundColor())
                .shadow(color: .black.opacity(0.1), radius: 3.5, x: 3, y: 3))
    }
    
    private func getForegroundColor() -> Color {
        switch buttonStyle {
        case .primary:
            return .white
        case .secondary:
            return .black
        }
    }
    
    private func getBackgroundColor() -> Color {
        switch buttonStyle {
        case .primary:
            return .black
        case .secondary:
            return .white
        }
    }
}

#Preview {
    ActionButton(text: "test", buttonStyle: .primary) {
        print(1)
    }
}
