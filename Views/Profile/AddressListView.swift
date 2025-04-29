//
//  AddressListView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

enum AddressListMode {
    case view
    case selection
}

struct AddressListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var addressViewModel: AddressViewModel
    
    let mode: AddressListMode
    var onAddressSelected: ((Address) -> Void)?
    
    @State private var showAddAddress = false
    @State private var showDeleteConfirmation = false
    @State private var addressToDelete: Address?
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if addressViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if addressViewModel.addresses.isEmpty {
                emptyStateView
            } else {
                addressListView
            }
        }
        .navigationTitle(mode == .selection ? "Select Address" : "Addresses")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    addressViewModel.addressToEdit = nil
                    showAddAddress = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.appPrimary)
                }
            }
            
            if mode == .selection {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddAddress) {
            NavigationView {
                AddAddressView(userId: authViewModel.userId)
                    .environmentObject(authViewModel)
                    .environmentObject(addressViewModel)
            }
        }
        .alert("Delete Address", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let address = addressToDelete {
                    Task {
                        await addressViewModel.deleteAddress(address)
                        addressToDelete = nil
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this address?")
        }
        .onAppear {
            loadAddresses()
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
                    addressViewModel.addressToEdit = nil
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
                ForEach(addressViewModel.addresses) { address in
                    AddressCard(
                        address: address,
                        isSelected: mode == .selection,
                        onSelect: mode == .selection ? { onAddressSelected?(address) } : nil,
                        onEdit: {
                            addressViewModel.editAddress(address)
                            showAddAddress = true
                        },
                        onDelete: {
                            addressToDelete = address
                            showDeleteConfirmation = true
                        },
                        onSetDefault: mode == .view ? {
                            Task {
                                await addressViewModel.setDefaultAddress(address)
                            }
                        } : nil
                    )
                }
            }
            .padding()
        }
    }
    
    private func loadAddresses() {
        guard !authViewModel.userId.isEmpty else { return }
        
        Task {
            await addressViewModel.loadAddresses(userId: authViewModel.userId)
        }
    }
}

// MARK: - Preview
struct AddressListView_Previews: PreviewProvider {
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
        
        let viewModel = AddressViewModel()
        viewModel.addresses = mockAddresses
        
        return Group {
            // View mode with addresses
            NavigationView {
                AddressListView(mode: .view)
                    .environmentObject(AuthViewModel())
                    .environmentObject(viewModel)
            }
            
            // Selection mode with addresses
            NavigationView {
                AddressListView(
                    mode: .selection,
                    onAddressSelected: { _ in }
                )
                .environmentObject(AuthViewModel())
                .environmentObject(viewModel)
            }
            
            // Empty state
            NavigationView {
                AddressListView(mode: .view)
                    .environmentObject(AuthViewModel())
                    .environmentObject(AddressViewModel())
            }
        }
    }
}   
