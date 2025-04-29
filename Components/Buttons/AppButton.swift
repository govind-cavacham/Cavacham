import SwiftUI

struct AppButton: View {
    enum Style {
        case primary
        case secondary
        case tertiary
        case destructive
        case custom(Color)
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return .appPrimary
            case .secondary:
                return .appSecondary
            case .tertiary:
                return .clear
            case .destructive:
                return .appError
            case .custom(let color):
                return color
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .tertiary:
                return .appPrimary
            case .primary, .secondary, .destructive, .custom:
                return .white
            }
        }
    }
    
    enum Size {
        case small
        case regular
        case large
        
        var padding: CGFloat {
            switch self {
            case .small:
                return 8
            case .regular:
                return 16
            case .large:
                return 20
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return .subheadline
            case .regular:
                return .headline
            case .large:
                return .title3
            }
        }
    }
    
    let title: String
    let icon: String?
    let action: () -> Void
    let style: Style
    let size: Size
    let isLoading: Bool
    let isFullWidth: Bool
    
    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void,
        style: Style = .primary,
        size: Size = .regular,
        isLoading: Bool = false,
        isFullWidth: Bool = true
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .font(size.font)
                }
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, size.padding)
            .padding(.vertical, size.padding / 2)
            .background(style.backgroundColor)
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}

// MARK: - Convenience Initializers
extension AppButton {
    init(title: String, action: @escaping () -> Void) {
        self.init(title: title, icon: nil, action: action)
    }
    
    init(title: String, icon: String, action: @escaping () -> Void) {
        self.init(title: title, icon: icon, action: action, style: .primary)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppButton(title: "Primary Button", action: {})
        
        AppButton(
            title: "Secondary Small",
            icon: "star.fill",
            action: {},
            style: .secondary,
            size: .small
        )
        
        AppButton(
            title: "Tertiary Large",
            action: {},
            style: .tertiary,
            size: .large,
            isFullWidth: false
        )
        
        AppButton(
            title: "Loading Button",
            action: {},
            isLoading: true
        )
        
        AppButton(
            title: "Delete",
            icon: "trash",
            action: {},
            style: .destructive
        )
    }
    .padding()
} 