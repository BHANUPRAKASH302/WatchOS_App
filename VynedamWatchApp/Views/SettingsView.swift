import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var jarvisService: JarvisService
    @State private var enableNotifications: Bool = true
    @State private var enableFallDetection: Bool = true
    @State private var hapticProfile: String = "Normal"
    
    let hapticProfiles = ["Gentle", "Normal", "Intense"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                    Text("Settings")
                        .font(.headline)
                }
                
                // Language Selection Picker
                VStack(alignment: .leading, spacing: 2) {
                    Text("App Language")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                    
                    Picker("Language", selection: $jarvisService.appLanguage) {
                        ForEach(jarvisService.availableLanguages, id: \.self) { lang in
                            Text(lang).tag(lang)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Haptic Intensity
                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic Feedback")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    Picker("Profile", selection: $hapticProfile) {
                        ForEach(hapticProfiles, id: \.self) { profile in
                            Text(profile).tag(profile)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 50)
                }
                
                // Toggles
                VStack(spacing: 4) {
                    Toggle("Smart Alerts", isOn: $enableNotifications)
                        .font(.system(size: 11))
                        .padding(.vertical, 2)
                    
                    Toggle("Fall Alerts", isOn: $enableFallDetection)
                        .font(.system(size: 11))
                        .padding(.vertical, 2)
                }
                
                // Info block
                VStack(alignment: .leading, spacing: 2) {
                    Text("Multi-Domain Assistant")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                    Text("Version 1.0.0 (Standalone)")
                        .font(.system(size: 7))
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 4)
        }
    }
}
