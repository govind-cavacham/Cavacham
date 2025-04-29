//
//  AddAddressView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let geocoder = CLGeocoder()
    @Published var locationError: String?
    
    func fetchLocationDetails(for pincode: String, completion: @escaping (Result<(city: String, state: String), Error>) -> Void) {
        // Indian PIN codes are 6 digits
        guard pincode.count == 6, let pin = Int(pincode) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid PIN code"])))
            return
        }
        
        // Create a search string for the geocoder
        let searchString = "\(pin), India"
        
        geocoder.geocodeAddressString(searchString) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let city = placemark.locality,
                  let state = placemark.administrativeArea else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location not found"])))
                return
            }
            
            completion(.success((city: city, state: state)))
        }
    }
}

struct AddAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var viewModel: AddressViewModel
    @StateObject private var locationManager = LocationManager()
    
    let userId: String
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var isDefault = false
    @State private var isSearchingLocation = false
    @State private var showLocationError = false
    @State private var locationErrorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact")) {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address Line 1", text: $addressLine1)
                        .textContentType(.streetAddressLine1)
                    
                    TextField("Address Line 2 (Optional)", text: $addressLine2)
                        .textContentType(.streetAddressLine2)
                    
                    HStack {
                        TextField("PIN Code", text: $postalCode)
                            .textContentType(.postalCode)
                            .keyboardType(.numberPad)
                            .onChange(of: postalCode) { newValue in
                                // Limit to 6 digits
                                if newValue.count > 6 {
                                    postalCode = String(newValue.prefix(6))
                                }
                                
                                // Auto-fetch location when PIN code is complete
                                if newValue.count == 6 {
                                    fetchLocationFromPinCode()
                                }
                            }
                        
                        if isSearchingLocation {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                    
                    TextField("City", text: $city)
                        .textContentType(.addressCity)
                    
                    TextField("State", text: $state)
                        .textContentType(.addressState)
                }
                
                Section {
                    Toggle("Set as Default Address", isOn: $isDefault)
                }
            }
            .navigationTitle(viewModel.addressToEdit == nil ? "Add Address" : "Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.addressToEdit = nil
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAddress()
                    }
                    .disabled(!isValidForm)
                }
            }
            .alert("Location Error", isPresented: $showLocationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(locationErrorMessage)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                if let address = viewModel.addressToEdit {
                    name = address.fullName
                    phoneNumber = address.phoneNumber ?? ""
                    addressLine1 = address.street
                    addressLine2 = address.apartment ?? ""
                    city = address.city
                    state = address.state
                    postalCode = address.zipCode
                    isDefault = address.isDefault
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !name.isEmpty && !phoneNumber.isEmpty && !addressLine1.isEmpty &&
        !city.isEmpty && !state.isEmpty && postalCode.count == 6
    }
    
    private func fetchLocationFromPinCode() {
        isSearchingLocation = true
        locationManager.fetchLocationDetails(for: postalCode) { result in
            isSearchingLocation = false
            
            switch result {
            case .success(let location):
                city = location.city
                state = location.state
            case .failure(let error):
                locationErrorMessage = error.localizedDescription
                showLocationError = true
            }
        }
    }
    
    private func saveAddress() {
        let address = Address(
            id: viewModel.addressToEdit?.id ?? UUID().uuidString,
            fullName: name,
            phoneNumber: phoneNumber,
            street: addressLine1,
            apartment: addressLine2.isEmpty ? nil : addressLine2,
            city: city,
            state: state,
            zipCode: postalCode,
            isDefault: isDefault,
            userId: userId
        )
        
        Task {
            if viewModel.addressToEdit != nil {
                await viewModel.updateAddress(address)
            } else {
                await viewModel.addAddress(address)
            }
            viewModel.addressToEdit = nil
            dismiss()
        }
    }
}
