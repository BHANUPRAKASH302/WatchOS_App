import SwiftUI

struct HomeView: View {
    @EnvironmentObject var jarvisService: JarvisService
    @EnvironmentObject var vitalsService: VitalsService
    @EnvironmentObject var locationService: LocationService
    
    @State private var crownIndex: Double = 0.0
    @State private var showSiren: Bool = false
    @State private var isPulse: Bool = false
    
    // Ordered list of domains for selector
    let domains: [Domain] = [.jarvis, .safeguard, .prescripto, .learning, .agrogen, .lawgen]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 4) {
                    // Top Header bar: Heart rate and settings
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .scaleEffect(isPulse ? 1.1 : 0.9)
                                .animation(.easeInOut(duration: 0.6).repeatForever(), value: isPulse)
                            Text("\(vitalsService.heartRate) BPM")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                    
                    // Domain Picker Card
                    let activeDomain = domains[Int(clamp(crownIndex, min: 0, max: Double(domains.count - 1)))]
                    
                    NavigationLink(destination: destinationView(for: activeDomain)) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Image(systemName: activeDomain.icon)
                                    .foregroundColor(activeDomain.themeColor)
                                    .font(.headline)
                                Text(activeDomain.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(activeDomain.description)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(activeDomain.themeColor.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(activeDomain.themeColor, lineWidth: 1.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Crown Indicator
                    HStack(spacing: 3) {
                        ForEach(0..<domains.count, id: \.self) { index in
                            Circle()
                                .fill(index == Int(crownIndex) ? domains[index].themeColor : Color.gray.opacity(0.5))
                                .frame(width: index == Int(crownIndex) ? 6 : 4, height: index == Int(crownIndex) ? 6 : 4)
                        }
                    }
                    .padding(.vertical, 2)
                    
                    // Bottom Controls: SOS and JARVIS voice
                    HStack(spacing: 8) {
                        Button(action: {
                            showSiren = true
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.shield.fill")
                                Text("SOS")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: JarvisView()) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("JARVIS")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.55, green: 0.35, blue: 0.95))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.bottom, 2)
            }
            .focusable(true)
            .digitalCrownRotation(
                $crownIndex,
                from: 0.0,
                through: Double(domains.count - 1),
                by: 1.0,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .fullScreenCover(isPresented: $showSiren) {
                SirenView()
            }
            .onAppear {
                isPulse = true
            }
        }
    }
    
    private func clamp(_ value: Double, min: Double, max: Double) -> Int {
        if value < min { return Int(min) }
        if value > max { return Int(max) }
        return Int(value)
    }
    
    @ViewBuilder
    private func destinationView(for domain: Domain) -> some View {
        switch domain {
        case .safeguard:
            SafeGuardView()
        case .prescripto:
            PrescriptoView()
        case .jarvis:
            JarvisView()
        case .learning:
            LearningView()
        case .agrogen:
            AgroGenView()
        case .lawgen:
            LawGenView()
        }
    }
}
