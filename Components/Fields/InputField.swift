//
//  InputField.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var trailingIcon: String? = nil
    var trailingIconAction: (() -> Void)? = nil
    var trailingIconColor: Color = .appPrimary
    var showLoader: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .labelMediumStyle()
                .foregroundColor(.appTextPrimary)
            
            HStack {
                // Leading icon
                Image(systemName: icon)
                    .foregroundColor(.appTextTertiary)
                    .frame(width: 24)
                
                // Text input
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .bodyMediumStyle()
                        .foregroundColor(.appTextPrimary)
                        .keyboardType(keyboardType)
                        .autocapitalization(.words)
                }
                
                // Trailing icon or loader
                if showLoader {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .appTextTertiary))
                        .scaleEffect(0.8)
                        .frame(width: 24, height: 24)
                } else if let trailingIcon = trailingIcon {
                    Button(action: {
                        trailingIconAction?()
                    }) {
                        Image(systemName: trailingIcon)
                            .foregroundColor(trailingIconColor)
                            .frame(width: 24, height: 24)
                    }
                    .disabled(trailingIconAction == nil)
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(12)
        }
    }
}

struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Name",
                placeholder: "Enter your name",
                text: .constant(""),
                icon: "person"
            )
            
            InputField(
                title: "Password",
                placeholder: "Enter your password",
                text: .constant(""),
                icon: "lock",
                isSecure: true,
                trailingIcon: "eye",
                trailingIconAction: {}
            )
            
            InputField(
                title: "PIN Code",
                placeholder: "Enter 6-digit PIN",
                text: .constant("110001"),
                icon: "map.circle",
                keyboardType: .numberPad,
                trailingIcon: "magnifyingglass",
                trailingIconAction: {},
                showLoader: true
            )
        }
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
} 