//
//  AppTextField.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct AppTextField: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .bodyMediumStyle()
                .foregroundColor(.appTextPrimary)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
        }
        .padding(16)
        .background(Color.appBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appTextTertiary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AppSecureField: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextSecondary)
                .frame(width: 24)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .bodyMediumStyle()
            .foregroundColor(.appTextPrimary)
            .autocapitalization(.none)
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(16)
        .background(Color.appBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appTextTertiary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AppTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AppTextField(
                placeholder: "Email",
                icon: "envelope",
                text: .constant(""),
                keyboardType: .emailAddress,
                autocapitalization: .none
            )
            
            AppSecureField(
                placeholder: "Password",
                icon: "lock",
                text: .constant("")
            )
        }
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
} 