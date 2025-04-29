//
//  UserProfileViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private let db = Firestore.firestore()
    
    var userInitials: String {
        let components = userName.components(separatedBy: " ")
        if components.isEmpty {
            return "?"
        } else if components.count == 1 {
            return String(components[0].prefix(1)).uppercased()
        } else {
            return "\(components[0].prefix(1))\(components.last?.prefix(1) ?? "")".uppercased()
        }
    }
    
    func loadUserProfile(userId: String) {
        isLoading = true
        
        Task {
            do {
                let document = try await db.collection("users").document(userId).getDocument()
                if let data = document.data() {
                    userName = data["name"] as? String ?? ""
                    email = data["email"] as? String ?? ""
                    phoneNumber = data["phoneNumber"] as? String ?? ""
                }
            } catch {
                showError(message: "Failed to load profile: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    func updateUserProfile(userId: String, name: String, phone: String) {
        isLoading = true
        
        let updateData: [String: Any] = [
            "name": name,
            "phoneNumber": phone,
            "updatedAt": Timestamp()
        ]
        
        Task {
            do {
                try await db.collection("users").document(userId).updateData(updateData)
                userName = name
                phoneNumber = phone
            } catch {
                showError(message: "Failed to update profile: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
} 