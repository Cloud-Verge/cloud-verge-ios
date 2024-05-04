//
//  LoginView.swift
//  CloudVerge
//
//  Created by Кириллов Артемий Михайлович on 01.05.2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var newUser = true
    @State private var loginSuccess = false
    
    var body: some View {
        if loginSuccess {
            MainView()
        } else {
            Background {
                GeometryReader { _ in
                    VStack {
                        VStack(alignment: .leading) {
                            Text(newUser ? "Create an account" : "Login")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .padding(.bottom, 100)
                            Text("Your email")
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                            TextField("", text: $email)
                                .frame(height: 56)
                                .font(.system(size: 16))
                                .padding(.horizontal, 16)
                                .textInputAutocapitalization(.never)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                }
                                .padding(.bottom, 16)
                            Text("Password")
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                            SecureField("", text: $password)
                                .frame(height: 56)
                                .padding(.horizontal, 16)
                                .textInputAutocapitalization(.never)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 251)
                        
                        ActionButton(text: newUser ? "Sign Up" : "Sign In",
                                     buttonStyle: .primary) {
                            NetworkService.sendAuthData(
                                endpoint: newUser ? "register" : "login",
                                email: email,
                                password: password
                            ) { status, token in
                                if status {
                                    UserDefaults.standard.setValue(email, forKey: "email")
                                    UserDefaults.standard.setValue(password, forKey: "password")
                                    if let token = token {
                                        UserDefaults.standard.setValue(token, forKey: "token")
                                    }
                                    self.loginSuccess.toggle()
                                }
                            }
                            
                        }
                                     .padding(.bottom, 15)
                    
                        Button(newUser ? "Or sign in" : "Or sign up") {
                            self.newUser.toggle()
                        }
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
    }
    
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView()
}
