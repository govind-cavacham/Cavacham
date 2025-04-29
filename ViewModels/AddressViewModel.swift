//
//  AddressViewModel.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class AddressViewModel: ObservableObject {
    @Published var addresses: [Address] = []
    @Published var isLoading = false
    @Published var showAddAddress = false
    @Published var showDeleteAlert = false
    @Published var addressToEdit: Address?
    @Published var error: Error?
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private var addressToDelete: Address?
    private let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // Load addresses for the current user
    func loadAddresses(userId: String) async {
        isLoading = true
        error = nil
        
        do {
            let snapshot = try await db.collection("addresses")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            addresses = snapshot.documents.compactMap { document in
                guard let data = document.data() as? [String: Any],
                      let address = Address.fromDictionary(data, id: document.documentID) else {
                    print("Failed to parse address for document: \(document.documentID)")
                    return nil
                }
                return address
            }
            
            // Sort addresses to put default address first
            addresses.sort { $0.isDefault && !$1.isDefault }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            print("⚠️ Error loading addresses: \(error.localizedDescription)")
        }
    }
    
    // Get the default address or first available
    func getDefaultAddress() -> Address? {
        return addresses.first(where: { $0.isDefault }) ?? addresses.first
    }
    
    // Add a new address
    func addAddress(_ address: Address) async {
        isLoading = true
        error = nil
        
        do {
            let data: [String: Any] = [
                "full_name": address.fullName,
                "phone_number": address.phoneNumber ?? "",
                "street": address.street,
                "apartment": address.apartment ?? "",
                "city": address.city,
                "state": address.state,
                "zip_code": address.zipCode,
                "is_default": address.isDefault,
                "user_id": address.userId,
                "country": address.country
            ]
            
            if addresses.isEmpty {
                // Make first address default
                let _ = try await db.collection("addresses").addDocument(data: data)
            } else {
                if address.isDefault {
                    // Update other addresses to not be default
                    await updateOtherAddressesDefaultStatus(to: false, except: nil)
                }
                let _ = try await db.collection("addresses").addDocument(data: data)
            }
            
            await loadAddresses(userId: address.userId)
            
        } catch {
            self.error = error
            print("⚠️ Error adding address: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // Update an existing address
    func updateAddress(_ address: Address) async {
        isLoading = true
        error = nil
        
        do {
            let data: [String: Any] = [
                "full_name": address.fullName,
                "phone_number": address.phoneNumber ?? "",
                "street": address.street,
                "apartment": address.apartment ?? "",
                "city": address.city,
                "state": address.state,
                "zip_code": address.zipCode,
                "is_default": address.isDefault,
                "user_id": address.userId,
                "country": address.country
            ]
            
            if address.isDefault {
                await updateOtherAddressesDefaultStatus(to: false, except: address.id)
            }
            
            try await db.collection("addresses").document(address.id).setData(data)
            
            await loadAddresses(userId: address.userId)
            
        } catch {
            self.error = error
            print("⚠️ Error updating address: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // Delete an address
    func deleteAddress(_ address: Address) async {
        isLoading = true
        error = nil
        
        do {
            try await db.collection("addresses").document(address.id).delete()
            
            await loadAddresses(userId: address.userId)
            
        } catch {
            self.error = error
            print("⚠️ Error deleting address: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // Set an address as default
    func setDefaultAddress(_ address: Address) async {
        isLoading = true
        error = nil
        
        do {
            await updateOtherAddressesDefaultStatus(to: false, except: address.id)
            var updatedAddress = address
            updatedAddress.isDefault = true
            await updateAddress(updatedAddress)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func updateOtherAddressesDefaultStatus(to status: Bool, except addressId: String?) async {
        let batch = db.batch()
        
        addresses.forEach { address in
            if address.id != addressId {
                let ref = db.collection("addresses").document(address.id)
                batch.updateData(["is_default": status], forDocument: ref)
            }
        }
        
        do {
            try await batch.commit()
        } catch {
            self.error = error
        }
    }
    
    func editAddress(_ address: Address) {
        addressToEdit = address
        showAddAddress = true
    }
    
    func deleteAddress(_ address: Address) {
        addressToDelete = address
        showDeleteAlert = true
    }
    
    func confirmDeleteAddress() async {
        guard let address = addressToDelete else { return }
        
        do {
            try await db.collection("addresses")
                .document(address.id)
                .delete()
            
            if let index = addresses.firstIndex(where: { $0.id == address.id }) {
                addresses.remove(at: index)
            }
        } catch {
            print("Error deleting address: \(error)")
        }
        
        addressToDelete = nil
    }
}
