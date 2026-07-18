import Foundation
import Combine

class VitalsService: ObservableObject {
    @Published var heartRate: Int = 72
    @Published var oxygenSaturation: Int = 98
    @Published var appointments: [Appointment] = []
    @Published var medications: [Medication] = []
    @Published var symptomLogs: [SymptomLog] = []
    @Published var healthScore: Int = 88
    
    private var timer: Timer?
    
    struct Appointment: Identifiable {
        let id = UUID()
        let doctorName: String
        let time: String
        let specialty: String
    }
    
    struct Medication: Identifiable {
        let id = UUID()
        let name: String
        let dosage: String
        let time: String
        var isTaken: Bool
    }
    
    struct SymptomLog: Identifiable {
        let id = UUID()
        let date: Date
        let painLevel: Int
        let breathlessness: Int
        let note: String
    }
    
    init() {
        // Load mock appointments
        appointments = [
            Appointment(doctorName: "Dr. Aditi Sharma", time: "10:30 AM", specialty: "Cardiologist"),
            Appointment(doctorName: "Dr. Rajesh Patel", time: "02:15 PM", specialty: "General Physician"),
            Appointment(doctorName: "Dr. Sarah D'Souza", time: "04:45 PM", specialty: "Dermatologist")
        ]
        
        // Load mock medications
        medications = [
            Medication(name: "Aspirin", dosage: "75mg", time: "08:00 AM", isTaken: true),
            Medication(name: "Metformin", dosage: "500mg", time: "01:00 PM", isTaken: false),
            Medication(name: "Atorvastatin", dosage: "20mg", time: "09:00 PM", isTaken: false)
        ]
        
        startSimulatingVitals()
    }
    
    func startSimulatingVitals() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Random walk for heart rate (drift around 60 - 100)
            let hrChange = Int.random(in: -3...3)
            self.heartRate = max(55, min(120, self.heartRate + hrChange))
            
            // Random walk for SpO2 (mostly 95 - 100)
            if Double.random(in: 0...1) > 0.8 {
                let spo2Change = Int.random(in: -1...1)
                self.oxygenSaturation = max(92, min(100, self.oxygenSaturation + spo2Change))
            }
            
            // Re-calculate health score based on heart rate and oxygen saturation
            var score = 95
            if self.heartRate > 100 || self.heartRate < 60 {
                score -= 10
            }
            if self.oxygenSaturation < 95 {
                score -= 15
            }
            self.healthScore = max(50, score)
        }
    }
    
    func toggleMedication(id: UUID) {
        if let index = medications.firstIndex(where: { $0.id == id }) {
            medications[index].isTaken.toggle()
        }
    }
    
    func logSymptom(pain: Int, breath: Int, note: String) {
        let log = SymptomLog(date: Date(), painLevel: pain, breathlessness: breath, note: note)
        symptomLogs.insert(log, at: 0)
    }
}
