//
//  AuthViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    @Published var isGuest = false
    @Published var userId: String = ""
    @Published var currentUser: FirebaseAuth.User?
    @Published var userData: [String: Any]?
    
    // MARK: - Services
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    // MARK: - Authentication Methods
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.isAuthenticated = user != nil
            self.userId = user?.uid ?? ""
            self.email = user?.email ?? ""
        }
    }
    
    func signIn() {
        guard validateSignIn() else { return }
        
        isLoading = true
        Task {
            do {
                let result = try await auth.signIn(withEmail: email, password: password)
                self.userId = result.user.uid
                self.email = result.user.email ?? ""
                isAuthenticated = true
                isGuest = false
                await loadUserData(userId: result.user.uid)
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    func signUp() {
        guard validateSignUp() else { return }
        
        isLoading = true
        Task {
            do {
                let result = try await auth.createUser(withEmail: email, password: password)
                self.userId = result.user.uid
                self.email = result.user.email ?? ""
                isAuthenticated = true
                isGuest = false
                
                // Create user document in Firestore
                try await db.collection("users").document(result.user.uid).setData([
                    "email": email,
                    "createdAt": Timestamp(),
                    "lastLoginAt": Timestamp()
                ])
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            isAuthenticated = false
            isGuest = false
            userId = ""
            email = ""
        } catch {
            handleError(error)
        }
    }
    
    func continueAsGuest() {
        isGuest = true
        isAuthenticated = false
    }
    
    func forgotPassword() {
        guard validateEmail() else { return }
        
        isLoading = true
        Task {
            do {
                try await auth.sendPasswordReset(withEmail: email)
                showMessage("Password reset email sent. Please check your inbox.")
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func validateSignIn() -> Bool {
        guard validateEmail() else { return false }
        guard !password.isEmpty else {
            showError(message: "Please enter your password")
            return false
        }
        return true
    }
    
    private func validateSignUp() -> Bool {
        guard validateEmail() else { return false }
        guard password.count >= 8 else {
            showError(message: "Password must be at least 8 characters")
            return false
        }
        guard password == confirmPassword else {
            showError(message: "Passwords do not match")
            return false
        }
        return true
    }
    
    private func validateEmail() -> Bool {
        guard !email.isEmpty else {
            showError(message: "Please enter your email")
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            showError(message: "Please enter a valid email")
            return false
        }
        return true
    }
    
    private func createUserProfile(userId: String) async throws {
        let userData: [String: Any] = [
            "email": email,
            "name": email.components(separatedBy: "@")[0],
            "createdAt": Timestamp(),
            "updatedAt": Timestamp(),
            "addresses": [],
            "wishlist": []
        ]
        
        try await db.collection("users").document(userId).setData(userData)
        self.userData = userData
    }
    
    private func loadUserData(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                self.userData = data
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage: String
        
        switch error {
        case let authError as AuthErrorCode:
            switch authError.code {
            case .invalidEmail:
                errorMessage = "Invalid email address"
            case .wrongPassword:
                errorMessage = "Incorrect password"
            case .userNotFound:
                errorMessage = "No account found with this email"
            case .emailAlreadyInUse:
                errorMessage = "An account with this email already exists"
            case .weakPassword:
                errorMessage = "Password is too weak"
            case .networkError:
                errorMessage = "Network error. Please try again"
            default:
                errorMessage = "An error occurred. Please try again"
            }
        default:
            errorMessage = "An unexpected error occurred"
        }
        
        showError(message: errorMessage)
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func showMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
} 
