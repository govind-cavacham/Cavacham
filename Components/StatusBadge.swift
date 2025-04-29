//
//  StatusBadge.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15))
            .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .yellow
        case .processing:
            return .blue
        case .shipped:
            return .purple
        case .delivered:
            return .green
        case .cancelled:
            return .red
        }
    }
}

struct StatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            StatusBadge(status: .pending)
            StatusBadge(status: .processing)
            StatusBadge(status: .shipped)
            StatusBadge(status: .delivered)
            StatusBadge(status: .cancelled)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 
