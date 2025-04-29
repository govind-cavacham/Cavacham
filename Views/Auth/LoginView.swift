//
//  LoginView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct LoginView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // View model
    @StateObject private var authService = AuthService()
    
    // Form state
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Navigation
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    
    // Callback
    var onLoginSuccess: (() -> Void)?
    
    // Initializer with optional callback
    init(onLoginSuccess: (() -> Void)? = nil) {
        self.onLoginSuccess = onLoginSuccess
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.appPrimary)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.appSecondary.opacity(0.1))
                                )
                            
                            Text("Welcome Back")
                                .displaySmallStyle()
                                .foregroundColor(.appTextPrimary)
                            
                            Text("Sign in to continue")
                                .titleSmallStyle()
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding(.top, 40)
                        
                        // Login Form
                        VStack(spacing: 20) {
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
                            
                            // Forgot password
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .labelMediumStyle()
                                    .foregroundColor(.appPrimary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 4)
                        }
                        .padding(.horizontal)
                        
                        // Login button
                        AppButton(
                            title: "Sign In",
                            icon: "arrow.right",
                            action: signIn,
                            isLoading: isLoading
                        )
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // OR separator
                        HStack {
                            Rectangle()
                                .fill(Color.appTextTertiary.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("OR")
                                .labelMediumStyle()
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.appTextTertiary.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 24)
                        
                        // Social login buttons
                        VStack(spacing: 16) {
                            // Google button
                            Button(action: {
                                // Google sign in
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text("Continue with Google")
                                        .labelLargeStyle()
                                        .foregroundColor(.appTextPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appSurface)
                                .cornerRadius(12)
                            }
                            
                            // Apple button
                            Button(action: {
                                // Apple sign in
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "apple.logo")
                                        .font(.title3)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text("Continue with Apple")
                                        .labelLargeStyle()
                                        .foregroundColor(.appTextPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appSurface)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Sign up prompt
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .bodyMediumStyle()
                                .foregroundColor(.appTextSecondary)
                            
                            Button(action: {
                                showSignUp = true
                            }) {
                                Text("Sign Up")
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
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
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
    
    private func signIn() {
        // Validate inputs
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter your email")
            return
        }
        
        guard !password.isEmpty else {
            showAlert("Please enter your password")
            return
        }
        
        isLoading = true
        
        // Perform sign in
        Task {
            do {
                let _ = try await authService.signIn(email: email, password: password)
                isLoading = false
                
                // Call success callback if provided
                if let onLoginSuccess = onLoginSuccess {
                    onLoginSuccess()
                }
                
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
} 