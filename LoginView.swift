//
//  LoginView.swift
//  Cavacham
//
//  Created by Govind Pathak on 13/04/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @AppStorage("userEmail") var userEmail: String?
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("NeumorphicBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Log In")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Color("NeumorphicText"))
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                        .foregroundColor(Color("NeumorphicText"))
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("NeumorphicBackground"))
                                .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                        )
                        .foregroundColor(Color("NeumorphicText"))
                    
                    if isLoading {
                        ProgressView()
                            .tint(Color("NeumorphicAccent"))
                    }
                    
                    Button(action: loginUser) {
                        Text("Log In")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                            .foregroundColor(Color("NeumorphicAccent"))
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                    }
                    
                    NavigationLink(destination: SignupView()) {
                        Text("Need an account? Sign up")
                            .foregroundColor(Color("NeumorphicAccent"))
                            .underline()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("NeumorphicBackground"))
                        .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                )
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("NeumorphicText"))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color("NeumorphicBackground"))
                                    .shadow(color: .white.opacity(0.7), radius: 4, x: -4, y: -4)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 4)
                            )
                    }
                }
            }
        }
    }
    
    private func loginUser() {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    userEmail = result?.user.email
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
