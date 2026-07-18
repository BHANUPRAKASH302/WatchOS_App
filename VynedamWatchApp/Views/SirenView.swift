import SwiftUI

struct SirenView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationService: LocationService
    @State private var countdown: Int = 3
    @State private var isAlertSent: Bool = false
    @State private var isRedBackground: Bool = true
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    let flashTimer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            (isRedBackground ? Color.red : Color(red: 0.3, green: 0.0, blue: 0.0))
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                if !isAlertSent {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.white)
                        .scaleEffect(isRedBackground ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 0.25), value: isRedBackground)
                    
                    Text("SOS PANIC")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Sending in \(countdown)...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("CANCEL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(.top, 4)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 42))
                        .foregroundColor(.green)
                    
                    Text("ALERT SENT")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("GPS Shared with Contacts")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("Lat: \(String(format: "%.4f", locationService.currentCoordinate.latitude))\nLon: \(String(format: "%.4f", locationService.currentCoordinate.longitude))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(4)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(4)
                    
                    Button(action: {
                        locationService.isSharingLiveLocation = false
                        dismiss()
                    }) {
                        Text("DISMISS")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(.top, 4)
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if !isAlertSent {
                if countdown > 1 {
                    countdown -= 1
                    playSOSMorseHaptic()
                } else {
                    isAlertSent = true
                    locationService.isSharingLiveLocation = true
                    playSuccessHaptic()
                }
            }
        }
        .onReceive(flashTimer) { _ in
            if !isAlertSent {
                isRedBackground.toggle()
            } else {
                isRedBackground = false // Solid dark
            }
        }
        .onAppear {
            playSOSMorseHaptic()
        }
    }
    
    private func playSOSMorseHaptic() {
        // Morse code SOS: ... --- ...
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        // Send a sequence of haptics
        device.play(.directionUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { device.play(.directionUp) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { device.play(.directionUp) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { device.play(.failure) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { device.play(.failure) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { device.play(.failure) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { device.play(.directionUp) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { device.play(.directionUp) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { device.play(.directionUp) }
        #endif
    }
    
    private func playSuccessHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
