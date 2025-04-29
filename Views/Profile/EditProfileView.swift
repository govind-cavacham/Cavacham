//
//  EditProfileView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UserProfileViewModel
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var showAlert = false
    let userId: String
    
    init(userId: String, viewModel: UserProfileViewModel) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Phone Number", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: .constant(viewModel.email))
                        .disabled(true)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                name = viewModel.userName
                phone = viewModel.phoneNumber
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    private func saveProfile() {
        Task {
            await viewModel.updateUserProfile(userId: userId, name: name, phone: phone)
            if !viewModel.showError {
                dismiss()
            }
        }
    }
} 