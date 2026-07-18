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
                // Headline
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.red)
                    Text("SafeGuard AI")
                        .font(.headline)
                }
                .padding(.bottom, 2)
                
                // Panic SOS
                Button(action: {
                    showSiren = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text("TRIGGER SOS")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .fullScreenCover(isPresented: $showSiren) {
                    SirenView()
                }
                
                // Share Location status
                Button(action: {
                    locationService.toggleLiveLocationSharing()
                    playToggleHaptic()
                }) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: locationService.isSharingLiveLocation ? "location.fill" : "location")
                                .foregroundColor(.yellow)
                            Text(locationService.isSharingLiveLocation ? "Sharing Live GPS" : "Share Live Location")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text("Lat: \(String(format: "%.4f", locationService.currentCoordinate.latitude)), Lon: \(String(format: "%.4f", locationService.currentCoordinate.longitude))")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(locationService.isSharingLiveLocation ? Color.yellow.opacity(0.15) : Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(locationService.isSharingLiveLocation ? Color.yellow : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Emergency Contacts list
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Contacts")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                    
                    ForEach(contacts, id: \.0) { contact in
                        Button(action: {
                            callNumber = contact.1
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(contact.0)
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(contact.1)
                                        .font(.system(size: 9))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                    .font(.caption2)
                            }
                            .padding(6)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Nearest Hospitals
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nearest Hospitals")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    ForEach(locationService.nearestHospitals) { hosp in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(hosp.name)
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Distance: \(hosp.distance)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.08))
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
