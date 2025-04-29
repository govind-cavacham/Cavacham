//
//  AppTypography.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct AppTypography {
    // Font families
    enum FontFamily: String {
        case primary = "Montserrat" // Replace with your desired font
        case secondary = "Playfair Display" // Replace with your desired font
        
        var name: String {
            return self.rawValue
        }
    }
    
    // Font weights
    enum FontWeight {
        case regular, medium, semiBold, bold
        
        var weight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semiBold: return .semibold
            case .bold: return .bold
            }
        }
    }
    
    // Font styles
    struct FontStyle {
        let family: FontFamily
        let size: CGFloat
        let weight: FontWeight
        
        func font() -> Font {
            // Using system font as fallback
            return Font.system(size: size, weight: weight.weight)
        }
    }
    
    // Predefined text styles
    static let displayLarge = FontStyle(family: .secondary, size: 40, weight: .bold)
    static let displayMedium = FontStyle(family: .secondary, size: 36, weight: .bold)
    static let displaySmall = FontStyle(family: .secondary, size: 32, weight: .bold)
    
    static let headingLarge = FontStyle(family: .secondary, size: 28, weight: .semiBold)
    static let headingMedium = FontStyle(family: .secondary, size: 24, weight: .semiBold)
    static let headingSmall = FontStyle(family: .primary, size: 20, weight: .semiBold)
    
    static let titleLarge = FontStyle(family: .primary, size: 22, weight: .bold)
    static let titleMedium = FontStyle(family: .primary, size: 18, weight: .semiBold)
    static let titleSmall = FontStyle(family: .primary, size: 16, weight: .semiBold)
    
    static let bodyLarge = FontStyle(family: .primary, size: 16, weight: .regular)
    static let bodyMedium = FontStyle(family: .primary, size: 14, weight: .regular)
    static let bodySmall = FontStyle(family: .primary, size: 12, weight: .regular)
    
    static let labelLarge = FontStyle(family: .primary, size: 14, weight: .medium)
    static let labelMedium = FontStyle(family: .primary, size: 12, weight: .medium)
    static let labelSmall = FontStyle(family: .primary, size: 10, weight: .medium)
}

// Text modifiers for easy use in SwiftUI
extension View {
    func displayLargeStyle() -> some View {
        self.font(AppTypography.displayLarge.font())
    }
    
    func displayMediumStyle() -> some View {
        self.font(AppTypography.displayMedium.font())
    }
    
    func displaySmallStyle() -> some View {
        self.font(AppTypography.displaySmall.font())
    }
    
    func headingLargeStyle() -> some View {
        self.font(AppTypography.headingLarge.font())
    }
    
    func headingMediumStyle() -> some View {
        self.font(AppTypography.headingMedium.font())
    }
    
    func headingSmallStyle() -> some View {
        self.font(AppTypography.headingSmall.font())
    }
    
    func titleLargeStyle() -> some View {
        self.font(AppTypography.titleLarge.font())
    }
    
    func titleMediumStyle() -> some View {
        self.font(AppTypography.titleMedium.font())
    }
    
    func titleSmallStyle() -> some View {
        self.font(AppTypography.titleSmall.font())
    }
    
    func bodyLargeStyle() -> some View {
        self.font(AppTypography.bodyLarge.font())
    }
    
    func bodyMediumStyle() -> some View {
        self.font(AppTypography.bodyMedium.font())
    }
    
    func bodySmallStyle() -> some View {
        self.font(AppTypography.bodySmall.font())
    }
    
    func labelLargeStyle() -> some View {
        self.font(AppTypography.labelLarge.font())
    }
    
    func labelMediumStyle() -> some View {
        self.font(AppTypography.labelMedium.font())
    }
    
    func labelSmallStyle() -> some View {
        self.font(AppTypography.labelSmall.font())
    }
} 