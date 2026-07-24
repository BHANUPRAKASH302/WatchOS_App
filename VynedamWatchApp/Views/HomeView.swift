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
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            // Top Header bar: Heart rate and settings
                            HStack {
                                HStack(spacing: 3) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .scaleEffect(isPulse ? 1.15 : 0.88)
                                        .animation(.easeInOut(duration: 0.6).repeatForever(), value: isPulse)
                                    Text("\(vitalsService.heartRate) BPM")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 4)
                            
                            // App Logo Banner Card
                            VStack(spacing: 4) {
                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.purple.opacity(0.6), lineWidth: 1.5))
                                    .shadow(color: .purple.opacity(0.4), radius: 4)
                                
                                Text("Multi-Domain Assistant")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text("Powered by Ollama Local LLM")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(Color.purple.opacity(0.8))
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(LinearGradient(
                                                colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 1)
                                    )
                            )
                            
                            // Bottom Controls: SOS and JARVIS AI (LLM)
                            HStack(spacing: 6) {
                                Button(action: {
                                    showSiren = true
                                }) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "exclamationmark.shield.fill")
                                            .font(.system(size: 10))
                                        Text("SOS")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(LinearGradient(
                                        colors: [Color.red, Color(red: 0.7, green: 0.0, blue: 0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .cornerRadius(8)
                                    .shadow(color: .red.opacity(0.4), radius: 2)
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(destination: JarvisView()) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 10))
                                        Text("JARVIS AI")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(LinearGradient(
                                        colors: [Color(red: 0.55, green: 0.35, blue: 0.95), Color(red: 0.35, green: 0.2, blue: 0.75)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .cornerRadius(8)
                                    .shadow(color: Color.purple.opacity(0.4), radius: 2)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 2)
                            
                            Divider()
                                .background(Color.white.opacity(0.12))
                                .padding(.vertical, 2)
                            
                            // Watch Options Label
                            HStack {
                                Text("Watch Options")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            // Scrollable list of domains with custom image icons
                            ForEach(0..<domains.count, id: \.self) { index in
                                let domain = domains[index]
                                let isHighlighted = index == Int(crownIndex)
                                
                                NavigationLink(destination: destinationView(for: domain).onAppear {
                                    jarvisService.selectedDomain = domain
                                }) {
                                    HStack(spacing: 8) {
                                        // Custom Image Icon replacing emojis
                                        Image(domain.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 28, height: 28)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(domain.themeColor, lineWidth: 1.5)
                                            )
                                            .shadow(color: domain.themeColor.opacity(0.4), radius: 3)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(domain.title)
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(domain.description)
                                                .font(.system(size: 8))
                                                .foregroundColor(.white.opacity(0.75))
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(isHighlighted ? domain.themeColor : .gray.opacity(0.6))
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isHighlighted ? domain.themeColor.opacity(0.18) : Color.white.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(isHighlighted ? domain.themeColor : Color.white.opacity(0.08), lineWidth: isHighlighted ? 1.5 : 1.0)
                                                    .shadow(color: isHighlighted ? domain.themeColor.opacity(0.5) : .clear, radius: 4)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                                .id(index)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    .onChange(of: crownIndex) { oldValue, newValue in
                        let targetIndex = Int(newValue)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(targetIndex, anchor: .center)
                        }
                    }
                }
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
