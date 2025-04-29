//
//  SettingsView.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("pushNotifications") private var pushNotifications = true
    @AppStorage("emailNotifications") private var emailNotifications = true
    @AppStorage("darkMode") private var darkMode = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Push Notifications", isOn: $pushNotifications)
                    Toggle("Email Notifications", isOn: $emailNotifications)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                Section(header: Text("About")) {
                    NavigationLink("Privacy Policy") {
                        WebView(url: URL(string: "https://www.cavacham.com/privacy")!)
                    }
                    
                    NavigationLink("Terms of Service") {
                        WebView(url: URL(string: "https://www.cavacham.com/terms")!)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAccountAlert = true
                    } label: {
                        Text("Delete Account")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
}

struct WebView: View {
    let url: URL
    
    var body: some View {
        // Placeholder for WebView implementation
        Text("Web content will be displayed here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
    }
} 