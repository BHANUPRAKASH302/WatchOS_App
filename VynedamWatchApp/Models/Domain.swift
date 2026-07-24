import SwiftUI

enum Domain: String, CaseIterable, Identifiable {
    case safeguard = "SafeGuard AI"
    case prescripto = "Prescripto"
    case jarvis = "JARVIS AI"
    case learning = "Learning"
    case agrogen = "AgroGen"
    case lawgen = "LawGen AI"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .safeguard: return "SafeGuard AI"
        case .prescripto: return "Prescripto"
        case .jarvis: return "JARVIS AI"
        case .learning: return "Learning"
        case .agrogen: return "AgroGen"
        case .lawgen: return "LawGen AI"
        }
    }
    
    var imageName: String {
        switch self {
        case .safeguard: return "Safety"
        case .prescripto: return "HealthCare"
        case .jarvis: return "AppLogo"
        case .learning: return "Education"
        case .agrogen: return "Agriculture"
        case .lawgen: return "LawGen"
        }
    }
    
    var icon: String {
        switch self {
        case .safeguard: return "shield.fill"
        case .prescripto: return "heart.text.square.fill"
        case .jarvis: return "brain.headprofile.fill"
        case .learning: return "book.closed.fill"
        case .agrogen: return "leaf.fill"
        case .lawgen: return "scalemass.fill"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .safeguard: return Color(red: 1.0, green: 0.23, blue: 0.19) // Red
        case .prescripto: return Color(red: 0.2, green: 0.8, blue: 0.6)   // Mint/Teal
        case .jarvis: return Color(red: 0.55, green: 0.35, blue: 0.95)   // Purple
        case .learning: return Color(red: 0.18, green: 0.5, blue: 0.98)  // Bright Blue
        case .agrogen: return Color(red: 0.3, green: 0.75, blue: 0.2)    // Green
        case .lawgen: return Color(red: 0.95, green: 0.6, blue: 0.1)     // Orange/Amber
        }
    }
    
    var description: String {
        switch self {
        case .safeguard: return "Emergency SOS, GPS, and active protection."
        case .prescripto: return "Vitals monitor, fall detection, and medical alerts."
        case .jarvis: return "Local LLM assistant powered by Ollama."
        case .learning: return "Bite-sized micro-flashcards and study streak."
        case .agrogen: return "Weather forecast, farm logs, and crop status."
        case .lawgen: return "Know your rights cards and legal resources."
        }
    }
}
