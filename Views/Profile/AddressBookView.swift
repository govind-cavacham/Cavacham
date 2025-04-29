//
//  AddressBookView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct AddressBookView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = AddressViewModel()
    
    @State private var showAddAddress = false
    @State private var showDeleteConfirmation = false
    @State private var addressToDelete: Address?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if viewModel.addresses.isEmpty {
                    emptyStateView
                } else {
                    addressListView
                }
            }
            .navigationTitle("Address Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.addressToEdit = nil // Clear for new address
                        showAddAddress = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.appPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddAddress) {
            NavigationView {
                AddAddressView(userId: authViewModel.userId)
                    .environmentObject(authViewModel)
                    .environmentObject(viewModel)
            }
        }
        .alert("Delete Address", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let address = addressToDelete {
                    Task {
                        await viewModel.deleteAddress(address)
                        addressToDelete = nil
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this address?")
        }
        .onAppear {
            Task {
                await viewModel.loadAddresses(userId: authViewModel.userId)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 48))
                .foregroundColor(.appTextTertiary)
            
            Text("No Addresses Found")
                .titleMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            Text("Add a new address to get started")
                .bodyLargeStyle()
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(
                title: "Add New Address",
                icon: "plus",
                action: {
                    viewModel.addressToEdit = nil
                    showAddAddress = true
                }
            )
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var addressListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.addresses) { address in
                    AddressCard(
                        address: address,
                        isSelected: false,
                        onSelect: nil,
                        onEdit: {
                            viewModel.editAddress(address)
                            showAddAddress = true
                        },
                        onDelete: {
                            addressToDelete = address
                            showDeleteConfirmation = true
                        },
                        onSetDefault: {
                            Task {
                                await viewModel.setDefaultAddress(address)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview
struct AddressBookView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAddresses = [
            Address(
                fullName: "John Doe",
                phoneNumber: "+91 9876543210",
                street: "123 Crystal Lane",
                apartment: "Apartment 4B",
                city: "Mumbai",
                state: "Maharashtra",
                zipCode: "400001",
                isDefault: true,
                userId: "USER123"
            ),
            Address(
                fullName: "Jane Smith",
                phoneNumber: "+91 9876543211",
                street: "456 Gem Street",
                apartment: nil,
                city: "Delhi",
                state: "Delhi",
                zipCode: "110001",
                isDefault: false,
                userId: "USER123"
            )
        ]
        
        return Group {
            // With addresses
            AddressBookView()
                .environmentObject(AuthViewModel())
                .onAppear {
                    let viewModel = AddressViewModel()
                    viewModel.addresses = mockAddresses
                }
            
            // Empty state
            AddressBookView()
                .environmentObject(AuthViewModel())
        }
    }
}
