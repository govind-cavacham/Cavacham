//
//  RefreshControl.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () async -> Void
    
    // Values to track pull offset and threshold
    @State private var offset: CGFloat = 0
    private let threshold: CGFloat = 80 // Pull distance required to trigger refresh
    
    var body: some View {
        GeometryReader { geo in
            if offset > 0 || isRefreshing {
                ZStack(alignment: .center) {
                    Color.clear
                    
                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                            .scaleEffect(1.5)
                    } else {
                        // Show arrow that rotates as user pulls down
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appPrimary)
                            .rotationEffect(.degrees(offset > threshold ? 180 : 0))
                            .animation(.easeInOut, value: offset > threshold)
                            .opacity(calculateOpacity(offset))
                    }
                }
                .frame(height: max(offset, isRefreshing ? threshold : 0))
                .offset(y: -offset)
            }
        }
        .frame(height: 0)
        .overlay {
            GeometryReader { geo -> Color in
                let frame = geo.frame(in: .global)
                let minY = frame.minY
                
                DispatchQueue.main.async {
                    if minY > 0 {
                        offset = minY
                    } else if !isRefreshing {
                        offset = 0
                    }
                    
                    // Trigger refresh when pulled past threshold and released
                    if offset > threshold && minY <= 0 && !isRefreshing {
                        isRefreshing = true
                        
                        // Call refresh action
                        Task {
                            await onRefresh()
                        }
                    }
                }
                
                return Color.clear
            }
        }
    }
    
    private func calculateOpacity(_ offset: CGFloat) -> CGFloat {
        if offset <= 0 {
            return 0.0
        }
        if offset >= 40.0 {
            return 1.0
        }
        return offset / 40.0
    }
}

// Helper types for measuring scroll offset
enum RefreshableKeyTypes {
    struct OffsetPreferenceKey: PreferenceKey {
        static let defaultValue: [Anchor<CGRect>] = []
        
        static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
            value.append(contentsOf: nextValue())
        }
    }
}

// View extension to make any view refreshable
extension View {
    func withRefreshControl(isRefreshing: Binding<Bool>, onRefresh: @escaping () async -> Void) -> some View {
        self.overlay(alignment: .top) {
            RefreshControl(isRefreshing: isRefreshing, onRefresh: onRefresh)
        }
    }
} 