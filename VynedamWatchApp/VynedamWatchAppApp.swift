import SwiftUI

@main
struct VynedamWatchAppApp: App {
    @StateObject private var jarvisService = JarvisService()
    @StateObject private var vitalsService = VitalsService()
    @StateObject private var locationService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(jarvisService)
                .environmentObject(vitalsService)
                .environmentObject(locationService)
        }
    }
}
