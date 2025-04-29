//
//  AddressFormView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct AddressFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    let address: Address?
    let onSave: (Address) -> Void
    
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var street: String = ""
    @State private var apartment: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var isDefault: Bool = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(address: Address? = nil, onSave: @escaping (Address) -> Void) {
        self.address = address
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Address Details")) {
                    TextField("Street Address", text: $street)
                    TextField("Apartment, Suite, etc. (optional)", text: $apartment)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("ZIP Code", text: $zipCode)
                        .keyboardType(.numberPad)
                }
                
                if address == nil {
                    Toggle("Set as Default Address", isOn: $isDefault)
                }
                
                Section {
                    AppButton(
                        title: address == nil ? "Add Address" : "Update Address",
                        icon: "checkmark",
                        action: saveAddress,
                        isLoading: isLoading
                    )
                }
            }
            .navigationTitle(address == nil ? "Add Address" : "Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let address = address {
                    fullName = address.fullName
                    phoneNumber = address.phoneNumber ?? ""
                    street = address.street
                    apartment = address.apartment ?? ""
                    city = address.city
                    state = address.state
                    zipCode = address.zipCode
                    isDefault = address.isDefault
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveAddress() {
        guard validateForm() else { return }
        
        isLoading = true
        
        let newAddress = Address(
            id: address?.id ?? UUID().uuidString,
            fullName: fullName,
            phoneNumber: phoneNumber,
            street: street,
            apartment: apartment.isEmpty ? nil : apartment,
            city: city,
            state: state,
            zipCode: zipCode,
            isDefault: isDefault,
            userId: authViewModel.userId
        )
        
        onSave(newAddress)
        dismiss()
    }
    
    private func validateForm() -> Bool {
        if fullName.isEmpty {
            showError(message: "Please enter your full name")
            return false
        }
        
        if phoneNumber.isEmpty {
            showError(message: "Please enter your phone number")
            return false
        }
        
        if street.isEmpty {
            showError(message: "Please enter your street address")
            return false
        }
        
        if city.isEmpty {
            showError(message: "Please enter your city")
            return false
        }
        
        if state.isEmpty {
            showError(message: "Please enter your state")
            return false
        }
        
        if zipCode.isEmpty {
            showError(message: "Please enter your ZIP code")
            return false
        }
        
        return true
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    AddressFormView(onSave: { _ in })
        .environmentObject(AuthViewModel())
} 
