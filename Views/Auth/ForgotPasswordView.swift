//
//  ForgotPasswordView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    // Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // View model
    @StateObject private var authService = AuthService()
    
    // Form state
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.appPrimary)
                            .padding(16)
                            .background(
                                Circle()
                                    .fill(Color.appSecondary.opacity(0.1))
                            )
                        
                        Text("Forgot Password?")
                            .headingLargeStyle()
                            .foregroundColor(.appTextPrimary)
                        
                        Text("Enter your email address and we'll send you a link to reset your password")
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 60)
                    
                    // Email input
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
                    .padding(.horizontal, 24)
                    
                    // Reset button
                    PrimaryButton(
                        title: isSuccess ? "Back to Login" : "Send Reset Link",
                        icon: isSuccess ? "arrow.left" : "paperplane",
                        isLoading: isLoading, action: isSuccess ? backToLogin : sendResetLink
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(isSuccess ? "Success" : "Error"),
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
    
    private func sendResetLink() {
        // Validate email
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter your email", isSuccess: false)
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: email) else {
            showAlert("Please enter a valid email address", isSuccess: false)
            return
        }
        
        isLoading = true
        
        // Send reset password email
        Task {
            do {
                try await authService.resetPassword(email: email)
                isLoading = false
                isSuccess = true
                showAlert("Password reset link has been sent to your email", isSuccess: true)
            } catch {
                isLoading = false
                showAlert(error.localizedDescription, isSuccess: false)
            }
        }
    }
    
    private func backToLogin() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func showAlert(_ message: String, isSuccess: Bool) {
        alertMessage = message
        self.isSuccess = isSuccess
        showingAlert = true
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
} 
