import SwiftUI
import Firebase

@main
struct UberDoctorApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var locationManager = LocationManager()
    
    init() {
        setupFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(locationManager)
        }
    }
    
    private func setupFirebase() {
        // Initialize Firebase - in a real app, you would add your Firebase configuration
        // FirebaseApp.configure()
    }
}