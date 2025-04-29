//
//  AuthService.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    // Published properties to track authentication state
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    // Initialize and set up authentication state listener
    init() {
        // Set up a listener for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user != nil ? User(from: user!) : nil
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // Register with email and password
    @MainActor
    func register(email: String, password: String, name: String) async throws -> User {
        isLoading = true
        error = nil
        
        do {
            // Create user with email and password
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Create user in Firestore (optional, depending on your data model)
            // await createUserInDatabase(authResult.user.uid, name: name, email: email)
            
            let user = User(from: authResult.user)
            self.currentUser = user
            self.isAuthenticated = true
            isLoading = false
            return user
        } catch {
            isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // Sign in with email and password
    @MainActor
    func signIn(email: String, password: String) async throws -> User {
        isLoading = true
        error = nil
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = User(from: authResult.user)
            self.currentUser = user
            self.isAuthenticated = true
            isLoading = false
            return user
        } catch {
            isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // Sign out
    @MainActor
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // Reset password
    @MainActor
    func resetPassword(email: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }
}

// User model to represent the authenticated user
struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    let photoURL: URL?
    
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.name = firebaseUser.displayName ?? ""
        self.photoURL = firebaseUser.photoURL
    }
} 