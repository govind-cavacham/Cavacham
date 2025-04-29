//
//  CavachamApp.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct CavachamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartViewModel)
                .environmentObject(authService)
        }
    }
    
    init() {
        // Use system fonts initially - can add custom fonts later
        setupAppearance()
    }
    
    private func setupAppearance() {
        // Configure system appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
