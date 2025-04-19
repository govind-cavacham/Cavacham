//
//  CavachamApp.swift
//  Cavacham
//
//  Created by Govind Pathak on 11/04/25.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct CavachamApp: App {
    @StateObject private var cartVM = CartViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(cartVM) // Inject at the app level
        }
    }
}
