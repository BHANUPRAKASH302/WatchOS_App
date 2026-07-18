import SwiftUI

struct PrescriptoView: View {
    @EnvironmentObject var vitalsService: VitalsService
    @State private var selectedPain: Double = 3.0
    @State private var selectedBreath: Double = 2.0
    @State private var loggedStatus: String? = nil
    @State private var isSimulatingFall: Bool = false
    @State private var fallCountdown: Int = 5
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Title
                HStack {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                    Text("Prescripto")
                        .font(.headline)
                }
                
                // Vitals Dashboard Card
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HEART RATE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(vitalsService.heartRate) BPM")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vitalsService.heartRate > 100 || vitalsService.heartRate < 60 ? .red : .green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BLOOD OXYGEN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(vitalsService.oxygenSaturation)% SpO2")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(vitalsService.oxygenSaturation < 95 ? .red : .blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                }
                
                // Fall Detection Simulator
                Button(action: {
                    isSimulatingFall = true
                    fallCountdown = 5
                    playAlertHaptic()
                }) {
                    HStack {
                        Image(systemName: "figure.fall")
                            .foregroundColor(.white)
                        Text(isSimulatingFall ? "Fall Detected (\(fallCountdown)s)" : "Simulate Hard Fall")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSimulatingFall ? Color.red : Color.orange.opacity(0.8))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(isSimulatingFall)
                
                // Medication Reminders
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medication Reminders")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    ForEach(vitalsService.medications) { med in
                        HStack {
                            Button(action: {
                                vitalsService.toggleMedication(id: med.id)
                                playSuccessHaptic()
                            }) {
                                Image(systemName: med.isTaken ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(med.isTaken ? .green : .gray)
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading) {
                                Text(med.name)
                                    .font(.system(size: 11, weight: .semibold))
                                    .strikethrough(med.isTaken)
                                    .foregroundColor(med.isTaken ? .gray : .white)
                                Text("\(med.dosage) • \(med.time)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            
                            if !med.isTaken {
                                Button(action: {
                                    loggedStatus = "Medication \(med.name) snoozed for 15 mins."
                                    playSnoozeHaptic()
                                }) {
                                    Text("Snooze")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(6)
                    }
                }
                
                // Appointments
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Bookings")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    ForEach(vitalsService.appointments) { appt in
                        VStack(alignment: .leading, spacing: 1) {
                            HStack {
                                Text(appt.doctorName)
                                    .font(.system(size: 11, weight: .semibold))
                                Spacer()
                                Text(appt.time)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                            }
                            Text(appt.specialty)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(6)
                    }
                }
                
                // Quick Symptom Logger
                VStack(alignment: .leading, spacing: 4) {
                    Text("Log Symptoms")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pain Level: \(Int(selectedPain))/10")
                            .font(.system(size: 10))
                        Slider(value: $selectedPain, in: 1...10, step: 1.0)
                            .tint(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Breathlessness: \(Int(selectedBreath))/10")
                            .font(.system(size: 10))
                        Slider(value: $selectedBreath, in: 1...10, step: 1.0)
                            .tint(.blue)
                    }
                    
                    Button(action: {
                        vitalsService.logSymptom(
                            pain: Int(selectedPain),
                            breath: Int(selectedBreath),
                            note: "Quick watch entry"
                        )
                        loggedStatus = "Logged: Pain \(Int(selectedPain)), Breath \(Int(selectedBreath))"
                        playSuccessHaptic()
                    }) {
                        Text("LOG SYMPTOMS")
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.2, green: 0.8, blue: 0.6))
                            .foregroundColor(.black)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
        }
        .onReceive(timer) { _ in
            if isSimulatingFall {
                if fallCountdown > 1 {
                    fallCountdown -= 1
                    playAlertHaptic()
                } else {
                    isSimulatingFall = false
                    loggedStatus = "FALL REPORTED! Emergency contacts notified."
                    playFallHaptic()
                }
            }
        }
        .alert(item: Binding<AlertItem?>(
            get: { loggedStatus.map { AlertItem(message: $0) } },
            set: { _ in loggedStatus = nil }
        )) { item in
            Alert(title: Text("Health Update"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func playSuccessHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
    
    private func playSnoozeHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.stop)
        #endif
    }
    
    private func playAlertHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.directionDown)
        #endif
    }
    
    private func playFallHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.failure)
        #endif
    }
    
    struct AlertItem: Identifiable {
        let id = UUID()
        let message: String
    }
}
