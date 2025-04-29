//
//  SignUpView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct SignUpView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // View model
    @StateObject private var authService = AuthService()
    
    // Form state
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var termsAccepted = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Create Account")
                                .displaySmallStyle()
                                .foregroundColor(.appTextPrimary)
                            
                            Text("Sign up to discover crystal magic")
                                .titleSmallStyle()
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.top, 40)
                        
                        // Sign Up Form
                        VStack(spacing: 20) {
                            // Name field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .labelMediumStyle()
                                    .foregroundColor(.appTextPrimary)
                                
                                TextField("Your Name", text: $name)
                                    .bodyMediumStyle()
                                    .padding()
                                    .background(Color.appSurface)
                                    .cornerRadius(12)
                            }
                            
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .labelMediumStyle()
                                    .foregroundColor(.appTextPrimary)
                                
                                TextField("your@email.com", text: $email)
                                    .bodyMediumStyle()
                                    .padding()
                                    .background(Color.appSurface)
                                    .cornerRadius(12)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .labelMediumStyle()
                                    .foregroundColor(.appTextPrimary)
                                
                                SecureField("••••••••", text: $password)
                                    .bodyMediumStyle()
                                    .padding()
                                    .background(Color.appSurface)
                                    .cornerRadius(12)
                            }
                            
                            // Confirm password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .labelMediumStyle()
                                    .foregroundColor(.appTextPrimary)
                                
                                SecureField("••••••••", text: $confirmPassword)
                                    .bodyMediumStyle()
                                    .padding()
                                    .background(Color.appSurface)
                                    .cornerRadius(12)
                            }
                            
                            // Terms and conditions
                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    termsAccepted.toggle()
                                }) {
                                    Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                                        .foregroundColor(termsAccepted ? .appPrimary : .appTextSecondary)
                                        .font(.title3)
                                }
                                
                                Text("I agree to the Terms & Conditions and Privacy Policy")
                                    .bodySmallStyle()
                                    .foregroundColor(.appTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        
                        // Sign Up button
                        AppButton(
                            title: "Create Account",
                            icon: "arrow.right",
                            action: signUp, isLoading: isLoading
                        )
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Already have account prompt
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .bodyMediumStyle()
                                .foregroundColor(.appTextSecondary)
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Sign In")
                                    .bodyMediumStyle()
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appPrimary)
                            }
                        }
                        .padding(.vertical, 32)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay(alignment: .topLeading) {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.appTextSecondary)
                        .padding(12)
                        .background(Color.appSurface)
                        .clipShape(Circle())
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Actions
    
    private func signUp() {
        // Validate inputs
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter your name")
            return
        }
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter your email")
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: email) else {
            showAlert("Please enter a valid email address")
            return
        }
        
        guard !password.isEmpty else {
            showAlert("Please enter your password")
            return
        }
        
        guard password.count >= 6 else {
            showAlert("Password must be at least 6 characters")
            return
        }
        
        guard password == confirmPassword else {
            showAlert("Passwords don't match")
            return
        }
        
        guard termsAccepted else {
            showAlert("Please accept our Terms & Conditions")
            return
        }
        
        isLoading = true
        
        // Perform sign up
        Task {
            do {
                let _ = try await authService.register(email: email, password: password, name: name)
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            } catch {
                isLoading = false
                showAlert(error.localizedDescription)
            }
        }
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
} 
