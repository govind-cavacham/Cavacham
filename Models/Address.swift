//
//  Address.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation
import FirebaseFirestore

struct Address: Identifiable, Codable {
    var id: String
    var fullName: String
    var phoneNumber: String?
    var street: String
    var apartment: String?
    var city: String
    var state: String
    var zipCode: String
    var isDefault: Bool
    var userId: String
    var country: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case street
        case apartment
        case city
        case state
        case zipCode = "zip_code"
        case isDefault = "is_default"
        case userId = "user_id"
        case country
    }
    
    init(id: String = UUID().uuidString,
         fullName: String,
         phoneNumber: String?,
         street: String,
         apartment: String?,
         city: String,
         state: String,
         zipCode: String,
         isDefault: Bool = false,
         userId: String,
         country: String = "India") {
        self.id = id
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.street = street
        self.apartment = apartment
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.isDefault = isDefault
        self.userId = userId
        self.country = country
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "full_name": fullName,
            "street": street,
            "city": city,
            "state": state,
            "zip_code": zipCode,
            "is_default": isDefault,
            "user_id": userId,
            "country": country
        ]
        
        if let phone = phoneNumber {
            dict["phone_number"] = phone
        }
        if let apt = apartment {
            dict["apartment"] = apt
        }
        
        return dict
    }
    
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Sample address for preview
    static var example: Address {
        Address(
            fullName: "John Doe",
            phoneNumber: "+91 9876543210",
            street: "123 Crystal Lane",
            apartment: "Apartment 4B",
            city: "Mumbai",
            state: "Maharashtra",
            zipCode: "400001",
            isDefault: true,
            userId: "",
            country: "India"
        )
    }
    
    // Convert dictionary to Address (for embedded addresses without ID)
    static func fromDictionary(_ dict: [String: Any]) -> Address? {
        guard let fullName = dict["full_name"] as? String,
              let street = dict["street"] as? String,
              let city = dict["city"] as? String,
              let state = dict["state"] as? String,
              let zipCode = dict["zip_code"] as? String,
              let userId = dict["user_id"] as? String else {
            print("Failed to parse embedded address")
            return nil
        }
        
        return Address(
            id: dict["id"] as? String ?? UUID().uuidString,
            fullName: fullName,
            phoneNumber: dict["phone_number"] as? String,
            street: street,
            apartment: dict["apartment"] as? String,
            city: city,
            state: state,
            zipCode: zipCode,
            isDefault: dict["is_default"] as? Bool ?? false,
            userId: userId,
            country: dict["country"] as? String ?? "India"
        )
    }
    
    // Convert dictionary to Address (for Firestore collection with ID)
    static func fromDictionary(_ dict: [String: Any], id: String) -> Address? {
        guard let fullName = dict["full_name"] as? String,
              let street = dict["street"] as? String,
              let city = dict["city"] as? String,
              let state = dict["state"] as? String,
              let zipCode = dict["zip_code"] as? String,
              let userId = dict["user_id"] as? String else {
            print("Failed to parse address with id: \(id)")
            return nil
        }
        
        return Address(
            id: id,
            fullName: fullName,
            phoneNumber: dict["phone_number"] as? String,
            street: street,
            apartment: dict["apartment"] as? String,
            city: city,
            state: state,
            zipCode: zipCode,
            isDefault: dict["is_default"] as? Bool ?? false,
            userId: userId,
            country: dict["country"] as? String ?? "India"
        )
    }
    
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "full_name": fullName,
            "street": street,
            "city": city,
            "state": state,
            "zip_code": zipCode,
            "is_default": isDefault,
            "user_id": userId,
            "country": country
        ]
        
        if let phone = phoneNumber {
            dict["phone_number"] = phone
        }
        if let apt = apartment {
            dict["apartment"] = apt
        }
        
        return dict
    }
}
