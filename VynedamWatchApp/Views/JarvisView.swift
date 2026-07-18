import SwiftUI

struct JarvisView: View {
    @EnvironmentObject var jarvisService: JarvisService
    @State private var isWaveAnimating = false
    
    var body: some View {
        VStack(spacing: 6) {
            // Header
            HStack {
                Image(systemName: "brain.headprofile.fill")
                    .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.95))
                Text("JARVIS AI")
                    .font(.headline)
            }
            
            if jarvisService.isListening {
                // Listening animation panel
                VStack(spacing: 8) {
                    Text("Listening...")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.purple)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.purple)
                                .frame(width: 4, height: isWaveAnimating ? CGFloat.random(in: 10...35) : 8)
                                .animation(
                                    .easeInOut(duration: 0.3)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.05),
                                    value: isWaveAnimating
                                )
                        }
                    }
                    .frame(height: 40)
                    .onAppear {
                        isWaveAnimating = true
                    }
                    .onDisappear {
                        isWaveAnimating = false
                    }
                    
                    Text("Ask about health, weather, rights...")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
                
            } else if jarvisService.isStreaming || !jarvisService.responseStream.isEmpty {
                // AI Response Panel
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Response:")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)
                        
                        Text(jarvisService.responseStream)
                            .font(.system(size: 11))
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if jarvisService.isStreaming {
                            HStack(spacing: 2) {
                                Circle().fill(Color.purple).frame(width: 3, height: 3)
                                Circle().fill(Color.purple).frame(width: 3, height: 3)
                                Circle().fill(Color.purple).frame(width: 3, height: 3)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    jarvisService.startListening()
                    playTapHaptic()
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Ask Again")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
            } else {
                // Idle state / Mic trigger button
                VStack(spacing: 12) {
                    Spacer()
                    
                    Button(action: {
                        jarvisService.startListening()
                        playTapHaptic()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 72, height: 72)
                            Circle()
                                .fill(Color.purple.opacity(0.25))
                                .frame(width: 60, height: 60)
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 48, height: 48)
                            Image(systemName: "mic.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text("Tap to Speak")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func playTapHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}
