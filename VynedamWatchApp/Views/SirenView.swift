import SwiftUI

struct SirenView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationService: LocationService
    
    @State private var countdown: Int = 3
    @State private var isAlertSent: Bool = false
    @State private var isPulse: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    let animationTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Dynamic Emergency Ambient Radial Gradient
            RadialGradient(
                gradient: Gradient(colors: isAlertSent ?
                    [Color(red: 0.12, green: 0.02, blue: 0.04), Color.black] :
                    [Color(red: 0.45, green: 0.05, blue: 0.08), Color(red: 0.1, green: 0.0, blue: 0.02), Color.black]),
                center: .center,
                startRadius: 5,
                endRadius: 160
            )
            .ignoresSafeArea()
            
            // Pulsing Ambient Ring Background
            if !isAlertSent {
                Circle()
                    .stroke(Color.red.opacity(0.35), lineWidth: 2)
                    .scaleEffect(pulseScale)
                    .opacity(2.0 - Double(pulseScale))
                    .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: pulseScale)
            }
            
            VStack(spacing: 6) {
                if !isAlertSent {
                    // Countdown State
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 64, height: 64)
                            .overlay(Circle().stroke(Color.red, lineWidth: 2))
                            .shadow(color: .red.opacity(0.8), radius: 8)
                        
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .scaleEffect(isPulse ? 1.1 : 0.95)
                    }
                    .padding(.top, 4)
                    
                    VStack(spacing: 2) {
                        Text("EMERGENCY SOS")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.red)
                        
                        Text("Sending in \(countdown)s...")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("GPS & Contacts Alerting")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("CANCEL SOS")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 2)
                } else {
                    // Alert Dispatched / Sent State
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 52, height: 52)
                            .overlay(Circle().stroke(Color.green, lineWidth: 2))
                            .shadow(color: .green.opacity(0.6), radius: 8)
                        
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 2)
                    
                    Text("ALERT DISPATCHED")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Glassmorphic Telemetry Info Card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.yellow)
                            Text("Live GPS Broadcast:")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Lat: \(String(format: "%.4f", locationService.currentCoordinate.latitude)) • Lon: \(String(format: "%.4f", locationService.currentCoordinate.longitude))")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.yellow)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.green)
                            Text("3 Emergency Contacts Notified")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    Button(action: {
                        locationService.isSharingLiveLocation = false
                        dismiss()
                    }) {
                        Text("DISMISS SOS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 2)
                }
            }
            .padding(.horizontal, 6)
        }
        .onReceive(timer) { _ in
            if !isAlertSent {
                if countdown > 1 {
                    countdown -= 1
                    playSOSMorseHaptic()
                } else {
                    withAnimation(.spring()) {
                        isAlertSent = true
                        locationService.isSharingLiveLocation = true
                    }
                    playSuccessHaptic()
                }
            }
        }
        .onReceive(animationTimer) { _ in
            isPulse.toggle()
        }
        .onAppear {
            pulseScale = 1.6
            playSOSMorseHaptic()
        }
    }
    
    private func playSOSMorseHaptic() {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        device.play(.directionUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { device.play(.directionUp) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { device.play(.directionUp) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { device.play(.failure) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { device.play(.failure) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { device.play(.directionUp) }
        #endif
    }
    
    private func playSuccessHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
