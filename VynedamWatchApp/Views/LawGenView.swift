import SwiftUI

struct LawGenView: View {
    @State private var selectedRightIndex = 0
    @State private var showCallAlert = false
    @State private var dialNumber = ""
    @State private var firId = ""
    @State private var firResult = ""
    
    let rights = [
        ("Arrest Grounds (CrPC 50)", "You must be immediately informed of the reasons for your arrest and your right to bail if bailable."),
        ("Right to Silence", "No person accused of an offense can be compelled to be a witness against themselves (Article 20(3))."),
        ("24-Hour Rule (CrPC 56)", "You must be produced before a Magistrate within 24 hours of arrest, excluding travel time."),
        ("Women Arrest Rule", "Women cannot be arrested after sunset and before sunrise except in exceptional circumstances with Magistrate sanction.")
    ]
    
    let helplineContacts = [
        ("NALSA Legal Aid", "15100"),
        ("Women Helpline", "1091"),
        ("National Helpline", "112")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                HStack(spacing: 6) {
                    Image(Domain.lawgen.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Domain.lawgen.themeColor, lineWidth: 1.5))
                        .shadow(color: Domain.lawgen.themeColor.opacity(0.4), radius: 3)
                    Text("LawGen AI")
                        .font(.headline)
                }
                
                // Rights browser
                VStack(alignment: .leading, spacing: 4) {
                    Text("Know Your Rights")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(rights[selectedRightIndex].0)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text(rights[selectedRightIndex].1)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            Button(action: {
                                if selectedRightIndex > 0 {
                                    selectedRightIndex -= 1
                                    playHaptic()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedRightIndex == 0)
                            
                            Spacer()
                            
                            Button(action: {
                                if selectedRightIndex < rights.count - 1 {
                                    selectedRightIndex += 1
                                    playHaptic()
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedRightIndex == rights.count - 1)
                        }
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1.0)
                    )
                }
                
                // Quick FIR Lookup Simulator
                VStack(alignment: .leading, spacing: 4) {
                    Text("FIR Status Check")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    VStack(spacing: 4) {
                        Button(action: {
                            queryFIR()
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Check FIR Status")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        
                        if !firResult.isEmpty {
                            Text(firResult)
                                .font(.system(size: 9))
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)
                                .padding(4)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Emergency Helpline Calls
                VStack(alignment: .leading, spacing: 4) {
                    Text("Helpline Services")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    ForEach(helplineContacts, id: \.0) { contact in
                        Button(action: {
                            dialNumber = contact.1
                            showCallAlert = true
                            playHaptic()
                        }) {
                            HStack {
                                Text(contact.0)
                                    .font(.system(size: 10, weight: .semibold))
                                Spacer()
                                Text(contact.1)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(6)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .alert(isPresented: $showCallAlert) {
            Alert(
                title: Text("Simulated Call"),
                message: Text("Calling Emergency Line \(dialNumber)..."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func queryFIR() {
        let statuses = [
            "FIR #2034/2026: Under active investigation. Forensic reports pending.",
            "FIR #1105/2026: Charge sheet submitted to Magistrate court.",
            "FIR #9084/2026: Case Closed. Settled via Mediation.",
            "FIR #5031/2026: Hearing scheduled for July 24."
        ]
        
        firResult = statuses.randomElement() ?? "FIR not found."
        playSuccessHaptic()
    }
    
    private func playHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
    
    private func playSuccessHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
