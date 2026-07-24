import SwiftUI

struct SafeGuardView: View {
    @EnvironmentObject var locationService: LocationService
    @State private var showSiren = false
    @State private var callNumber: String? = nil
    
    let contacts = [
        ("Mom (Primary)", "+91 98765 43210"),
        ("Dad", "+91 98765 43211"),
        ("Sister", "+91 98765 43212")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Headline Header with custom image
                HStack(spacing: 6) {
                    Image(Domain.safeguard.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.red, lineWidth: 1.5))
                        .shadow(color: .red.opacity(0.4), radius: 3)
                    
                    Text("SafeGuard AI")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 2)
                
                // Panic SOS Trigger Button Card
                Button(action: {
                    showSiren = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("TRIGGER SOS")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white)
                            Text("Instant Siren & GPS Dispatch")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color(red: 0.65, green: 0.0, blue: 0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: .red.opacity(0.5), radius: 4)
                }
                .buttonStyle(.plain)
                .fullScreenCover(isPresented: $showSiren) {
                    SirenView()
                }
                
                // Live Location sharing widget
                Button(action: {
                    locationService.toggleLiveLocationSharing()
                    playToggleHaptic()
                }) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Image(systemName: locationService.isSharingLiveLocation ? "location.fill" : "location")
                                .foregroundColor(locationService.isSharingLiveLocation ? .green : .yellow)
                                .font(.system(size: 10))
                            
                            Text(locationService.isSharingLiveLocation ? "Sharing Live GPS" : "Share Live Location")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Circle()
                                .fill(locationService.isSharingLiveLocation ? Color.green : Color.yellow)
                                .frame(width: 6, height: 6)
                        }
                        
                        Text("Lat: \(String(format: "%.4f", locationService.currentCoordinate.latitude)), Lon: \(String(format: "%.4f", locationService.currentCoordinate.longitude))")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(7)
                    .background(locationService.isSharingLiveLocation ? Color.green.opacity(0.12) : Color.white.opacity(0.06))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(locationService.isSharingLiveLocation ? Color.green.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Emergency Contacts list
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Contacts")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 2)
                    
                    ForEach(contacts, id: \.0) { contact in
                        Button(action: {
                            callNumber = contact.1
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Text(String(contact.0.prefix(1)))
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.red)
                                    )
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(contact.0)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(contact.1)
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 10))
                            }
                            .padding(6)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Nearest Hospitals
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nearest Hospitals")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 2)
                        .padding(.top, 2)
                    
                    ForEach(locationService.nearestHospitals) { hosp in
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(hosp.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Distance: \(hosp.distance)")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 11))
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .alert(item: Binding<AlertItem?>(
            get: { callNumber.map { AlertItem(message: "Calling \($0)...") } },
            set: { _ in callNumber = nil }
        )) { item in
            Alert(title: Text("Simulated Call"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func playToggleHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
    
    struct AlertItem: Identifiable {
        let id = UUID()
        let message: String
    }
}
