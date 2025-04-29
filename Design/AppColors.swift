//
//  AppColors.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct AppColors {
    // Primary colors
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")
    
    // Neutrals
    static let background = Color("Background")
    static let foreground = Color("Foreground")
    static let surface = Color("Surface")
    
    // Text colors
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    
    // Status colors
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
    static let info = Color("Info")
    
    // App-specific colors
    static let crystal = Color("Crystal")
    static let energy = Color("Energy")
}

// Extension to use the colors directly from Color
extension Color {
    static var appPrimary = AppColors.primary
    static var appSecondary = AppColors.secondary
    static var appAccent = AppColors.accent
    static var appBackground = AppColors.background
    static var appForeground = AppColors.foreground
    static var appSurface = AppColors.surface
    static var appTextPrimary = AppColors.textPrimary
    static var appTextSecondary = AppColors.textSecondary
    static var appTextTertiary = AppColors.textTertiary
    static var appSuccess = AppColors.success
    static var appWarning = AppColors.warning
    static var appError = AppColors.error
    static var appInfo = AppColors.info
    static var appCrystal = AppColors.crystal
    static var appEnergy = AppColors.energy
}

// Default color scheme for light/dark mode fallbacks
extension AppColors {
    // Fallback colors if the asset catalog colors are not available
    static func fallbackColors() {
        if Color("Primary") == Color.black {
            Color.appPrimary = Color(hex: "#7B61FF")
            Color.appSecondary = Color(hex: "#CB9BFF")
            Color.appAccent = Color(hex: "#FFD166")
            Color.appBackground = Color(hex: "#FFFFFF")
            Color.appForeground = Color(hex: "#1A1A1A")
            Color.appSurface = Color(hex: "#F7F7F7")
            Color.appTextPrimary = Color(hex: "#1A1A1A")
            Color.appTextSecondary = Color(hex: "#6C6C6C")
            Color.appTextTertiary = Color(hex: "#B3B3B3")
            Color.appSuccess = Color(hex: "#06D6A0")
            Color.appWarning = Color(hex: "#FFD166")
            Color.appError = Color(hex: "#EF476F")
            Color.appInfo = Color(hex: "#118AB2")
            Color.appCrystal = Color(hex: "#B5DEFF")
            Color.appEnergy = Color(hex: "#FFCDB2")
        }
    }
}

// Helper extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
