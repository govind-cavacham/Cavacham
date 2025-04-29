import SwiftUI

struct AddressCard: View {
    let address: Address
    let isSelected: Bool?
    let onSelect: (() -> Void)?
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name and default badge
            HStack {
                Text(address.fullName)
                    .titleSmallStyle()
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                if address.isDefault {
                    Text("Default")
                        .labelSmallStyle()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appEnergy)
                        .cornerRadius(12)
                }
                
                if let isSelected = isSelected {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .appPrimary : .appTextTertiary)
                        .font(.title3)
                }
            }
            
            // Phone
            if let phone = address.phoneNumber {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.appTextTertiary)
                        .font(.footnote)
                    
                    Text(phone)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            // Address
            HStack(alignment: .top) {
                Image(systemName: "house.fill")
                    .foregroundColor(.appTextTertiary)
                    .font(.footnote)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.street)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                    
                    if let apt = address.apartment, !apt.isEmpty {
                        Text(apt)
                            .bodyMediumStyle()
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Text("\(address.city), \(address.state) \(address.zipCode)")
                        .bodyMediumStyle()
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            // Action buttons
            if onSelect == nil { // Only show actions if not in selection mode
                HStack {
                    Spacer()
                    
                    // Edit button
                    Button(action: onEdit) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.footnote)
                            Text("Edit")
                                .labelMediumStyle()
                        }
                        .foregroundColor(.appPrimary)
                    }
                    
                    Spacer()
                    
                    // Make default button
                    if let onSetDefault = onSetDefault, !address.isDefault {
                        Button(action: onSetDefault) {
                            HStack(spacing: 4) {
                                Image(systemName: "star")
                                    .font(.footnote)
                                Text("Set Default")
                                    .labelMediumStyle()
                            }
                            .foregroundColor(.appEnergy)
                        }
                        
                        Spacer()
                    }
                    
                    // Delete button
                    Button(action: onDelete) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.footnote)
                            Text("Delete")
                                .labelMediumStyle()
                        }
                        .foregroundColor(.appError)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected == true ? Color.appPrimary : Color.clear,
                    lineWidth: isSelected == true ? 2 : 0
                )
        )
        .onTapGesture {
            if let onSelect = onSelect {
                onSelect()
            }
        }
    }
} 