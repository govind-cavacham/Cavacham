//
//  AuthenticationView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()
    @State private var authMode: AuthMode = .signIn
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo and Welcome Text
                        welcomeSection
                        
                        // Auth Form
                        authForm
                            .background(Color.white)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(Color.white.opacity(0.2))
                .cornerRadius(25)
            
            Text(authMode == .signIn ? "Welcome Back!" : "Create Account")
                .titleLargeStyle()
                .foregroundColor(.white)
            
            Text(authMode == .signIn ? "Sign in to continue" : "Sign up to get started")
                .bodyLargeStyle()
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var authForm: some View {
        VStack(spacing: 24) {
            // Email Field
            AppTextField(
                placeholder: "Email",
                icon: "envelope",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .none
            )
            
            // Password Field
            AppSecureField(
                placeholder: "Password",
                icon: "lock",
                text: $viewModel.password
            )
            
            // Confirm Password Field (Sign Up only)
            if authMode == .signUp {
                AppSecureField(
                    placeholder: "Confirm Password",
                    icon: "lock",
                    text: $viewModel.confirmPassword
                )
            }
            
            // Forgot Password (Sign In only)
            if authMode == .signIn {
                Button(action: { viewModel.forgotPassword() }) {
                    Text("Forgot Password?")
                        .labelMediumStyle()
                        .foregroundColor(.appPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Submit Button
            PrimaryButton(
                title: "Sign In",
                isLoading: viewModel.isLoading, action: { Task { await viewModel.signIn() } }
            )
            
            // Switch Auth Mode
            Button(action: { authMode.toggle() }) {
                Text(authMode == .signIn ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                    .labelMediumStyle()
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(24)
    }
}

// MARK: - Auth Mode
enum AuthMode {
    case signIn, signUp
    
    mutating func toggle() {
        self = self == .signIn ? .signUp : .signIn
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
} 
