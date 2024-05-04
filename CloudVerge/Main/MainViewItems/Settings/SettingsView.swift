//
//  SettingsView.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 03.05.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var email = UserDefaults.standard.value(forKey: "email") as? String ?? "Email not set"
    @State private var password = UserDefaults.standard.value(forKey: "password") as? String ?? "Password not set"
    @State private var token = UserDefaults.standard.value(forKey: "token") as? String ?? "None"
    @State private var newPassword = ""
    @State private var passChange: Bool = false
    
    @State private var showingSuccessAlert = false
    @State private var showingFailureAlert = false
    
    var body: some View {
        Background {
            GeometryReader { _ in
                VStack {
                    VStack(alignment: .leading) {
                        Text("Your profile")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .padding(.bottom, 50)
                            .padding(.top, 75)
                        Text("Your email")
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .padding(.bottom, 10)
                        Text(email)
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .padding(.bottom, 20)
                        Text("Your password")
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .padding(.bottom, 10)
                        if passChange {
                            SecureField("", text: $newPassword)
                                .frame(height: 56)
                                .padding(.horizontal, 16)
                                .textInputAutocapitalization(.never)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                        } else {
                            Text(password)
                                .font(.system(size: 18))
                                .fontWeight(.regular)
                                .padding(.bottom, 16)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    ActionButton(text: passChange ? "Save password" : "Change password",
                                 buttonStyle: passChange ? .secondary : .primary) {
                        if passChange {
                            UserDefaults.standard.setValue(newPassword, forKey: "password")
                            SettingsNetworkService.updatePassword(password: newPassword,
                                                                  token: token) { result in
                                if result {
                                    self.endEditing()
                                    showingSuccessAlert.toggle()
                                } else {
                                    showingFailureAlert.toggle()
                                }
                            }
                        }
                        self.passChange.toggle()
                    }
                    .alert("Password updated successfully", isPresented: $showingSuccessAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("Password update failed", isPresented: $showingFailureAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    
                    Spacer()
                    
                }
                .preferredColorScheme(.light)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture {
            self.endEditing()
        }
    }
    
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SettingsView()
}
