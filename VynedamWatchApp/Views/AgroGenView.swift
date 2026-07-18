import SwiftUI

struct AgroGenView: View {
    @State private var irrigationActive = false
    @State private var irrigationSeconds = 0
    @State private var timer: Timer?
    @State private var loggedFarmNote = ""
    @State private var showSavedAlert = false
    
    // Ticker Crop prices
    let marketPrices = [
        ("Rice (Basmati)", "₹4,200/Qtl", "+2.4%"),
        ("Wheat (Kalyan)", "₹2,150/Qtl", "-0.8%"),
        ("Cotton (Long)", "₹7,800/Qtl", "+4.1%"),
        ("Sugarcane", "₹315/Qtl", "Stable")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color(red: 0.3, green: 0.75, blue: 0.2))
                    Text("AgroGen")
                        .font(.headline)
                }
                
                // Weather Widget Card
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Image(systemName: "cloud.sun.rain.fill")
                            .foregroundColor(.yellow)
                        Text("Northern Field")
                            .font(.system(size: 11, weight: .bold))
                        Spacer()
                        Text("Live")
                            .font(.system(size: 8))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green)
                            .cornerRadius(3)
                    }
                    
                    HStack {
                        Text("29°C")
                            .font(.system(size: 20, weight: .bold))
                        VStack(alignment: .leading) {
                            Text("Rain Prob: 75%")
                                .font(.system(size: 8))
                            Text("Humidity: 88%")
                                .font(.system(size: 8))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("Sow within 3 days for maximum yield.")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                        .padding(.top, 1)
                }
                .padding(6)
                .background(Color.green.opacity(0.12))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1.0)
                )
                
                // Crop Growth Tracker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Crop: Basmati Rice")
                        .font(.system(size: 11, weight: .bold))
                    
                    HStack {
                        Text("Tillering Phase")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("58 days left")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(red: 0.3, green: 0.75, blue: 0.2))
                    }
                    
                    // Simple progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.15))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 0.3, green: 0.75, blue: 0.2))
                                .frame(width: geo.size.width * 0.45)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(8)
                
                // Irrigation Timer
                VStack(alignment: .leading, spacing: 4) {
                    Text("Irrigation Scheduler")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(irrigationActive ? "Pump Active" : "Pump Offline")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(irrigationActive ? .green : .gray)
                            Text(formatTime(irrigationSeconds))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        Spacer()
                        
                        Button(action: {
                            toggleIrrigation()
                        }) {
                            Text(irrigationActive ? "STOP" : "START")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(irrigationActive ? Color.red : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(6)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(8)
                }
                
                // Market Prices List
                VStack(alignment: .leading, spacing: 4) {
                    Text("MSP Mandi Prices")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    ForEach(marketPrices, id: \.0) { item in
                        HStack {
                            Text(item.0)
                                .font(.system(size: 9, weight: .semibold))
                            Spacer()
                            Text(item.1)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.8))
                            Text(item.2)
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(item.2.contains("+") ? .green : (item.2.contains("-") ? .red : .gray))
                        }
                        .padding(5)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(4)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func toggleIrrigation() {
        irrigationActive.toggle()
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
        
        if irrigationActive {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                irrigationSeconds += 1
            }
        } else {
            timer?.invalidate()
            timer = nil
            irrigationSeconds = 0
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}
