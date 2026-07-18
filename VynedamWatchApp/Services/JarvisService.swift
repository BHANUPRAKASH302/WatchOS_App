import Foundation
import Combine
import SwiftUI

class JarvisService: ObservableObject {
    @Published var selectedDomain: Domain = .jarvis
    @Published var isListening: Bool = false
    @Published var responseStream: String = ""
    @Published var isStreaming: Bool = false
    @Published var conversationHistory: [ChatMessage] = []
    
    // Streaks and Stats
    @Published var learningStreak: Int = 5
    @Published var dailyGoalProgress: Double = 0.6 // 60%
    
    // Language Preferences
    @Published var appLanguage: String = "English"
    let availableLanguages = ["English", "Hindi (हिन्दी)", "Telugu (తెలుగు)", "Tamil (தமிழ்)", "Kannada (ಕನ್ನಡ)", "Spanish (Español)"]
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let isUser: Bool
        let text: String
        let timestamp: Date = Date()
    }
    
    // Simple localized answers for mock translation/responses
    private let mockDatabase: [String: [String: String]] = [
        "heart": [
            "English": "Your current heart rate is stable at around 72 BPM. No abnormalities detected.",
            "Hindi (हिन्दी)": "आपकी हृदय गति लगभग 72 BPM पर स्थिर है। कोई असामान्यता नहीं पाई गई।",
            "Telugu (తెలుగు)": "మీ గుండె కొట్టుకునే వేగం 72 BPM వద్ద స్థిరంగా ఉంది. ఎలాంటి అసాధారణతలు లేవు.",
            "Tamil (தமிழ்)": "உங்கள் இதயத் துடிப்பு சுமார் 72 BPM இல் சீராக உள்ளது. அசாதாரணங்கள் எதுவும் இல்லை."
        ],
        "weather": [
            "English": "Today will be 29°C with scattered showers. Perfect for light weeding in the northern field.",
            "Hindi (हिन्दी)": "आज बिखरी हुई बारिश के साथ तापमान 29°C रहेगा। उत्तरी खेत में निराई के लिए उत्तम दिन है।",
            "Telugu (తెలుగు)": "ఈ రోజు 29°C ఉష్ణోగ్రతతో పాటు అక్కడక్కడ వర్షాలు పడవచ్చు. ఉత్తర పొలంలో పనులకు అనుకూలం.",
            "Tamil (தமிழ்)": "இன்று 29°C வெப்பநிலையுடன் பரவலாக மழை பெய்யக்கூடும். வடக்கு வயலில் வேலை செய்ய ஏற்ற நாள்."
        ],
        "rights": [
            "English": "Under Section 50 of CrPC, you have the right to know the grounds of your arrest and seek bail.",
            "Hindi (हिन्दी)": "CrPC की धारा 50 के तहत, आपको अपनी गिरफ्तारी का आधार जानने और जमानत लेने का अधिकार है।",
            "Telugu (తెలుగు)": "CrPC సెక్షన్ 50 ప్రకారం, మీ అరెస్టుకు గల కారణాలను తెలుసుకునే హక్కు మరియు బెయిల్ పొందే హక్కు మీకు ఉన్నాయి.",
            "Tamil (தமிழ்)": "CrPC பிரிவு 50-ன் கீழ், நீங்கள் ஏன் கைது செய்யப்படுகிறீர்கள் என்பதை அறியவும் பிணை பெறவும் உங்களுக்கு உரிமை உண்டு."
        ],
        "default": [
            "English": "I am analyzing your data. Keep monitoring your vitals and crops daily.",
            "Hindi (हिन्दी)": "मैं आपके डेटा का विश्लेषण कर रहा हूँ। दैनिक रूप से अपने स्वास्थ्य और फसलों की निगरानी करते रहें।",
            "Telugu (తెలుగు)": "నేను మీ సమాచారాన్ని విశ్లేషిస్తున్నాను. రోజువారీగా మీ ఆరోగ్యం మరియు పంటలను పర్యవేక్షిస్తూ ఉండండి.",
            "Tamil (தமிழ்)": "நான் உங்கள் தரவை பகுப்பாய்வு செய்கிறேன். உங்கள் உடல்நிலை மற்றும் பயிர்களை தினமும் கண்காணித்து வாருங்கள்."
        ]
    ]
    
    func startListening() {
        isListening = true
        responseStream = ""
        
        // Simulating 2.5s speech input before query triggers
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            self.isListening = false
            self.processVoiceQuery()
        }
    }
    
    private func processVoiceQuery() {
        let userQueries = [
            "How is my heart rate?",
            "What is the farm weather today?",
            "What are my basic legal rights?",
            "Explain micro-learning options."
        ]
        
        let chosenQuery = userQueries.randomElement() ?? "How is my heart rate?"
        conversationHistory.append(ChatMessage(isUser: true, text: chosenQuery))
        
        // Determine topic key
        var topicKey = "default"
        if chosenQuery.contains("heart") {
            topicKey = "heart"
        } else if chosenQuery.contains("weather") {
            topicKey = "weather"
        } else if chosenQuery.contains("rights") {
            topicKey = "rights"
        }
        
        // Get localized response
        let fullResponse = mockDatabase[topicKey]?[appLanguage] ?? mockDatabase[topicKey]?["English"] ?? "JARVIS Response simulated."
        
        // Stream the response back word-by-word
        isStreaming = true
        let words = fullResponse.components(separatedBy: " ")
        var currentWordIndex = 0
        responseStream = ""
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if currentWordIndex < words.count {
                self.responseStream += (currentWordIndex == 0 ? "" : " ") + words[currentWordIndex]
                currentWordIndex += 1
            } else {
                timer.invalidate()
                self.isStreaming = false
                self.conversationHistory.append(ChatMessage(isUser: false, text: self.responseStream))
                
                // Triggers a click haptic on final word
                #if os(watchOS)
                WKInterfaceDevice.current().play(.click)
                #endif
            }
        }
    }
    
    func incrementStreak() {
        learningStreak += 1
        dailyGoalProgress = min(1.0, dailyGoalProgress + 0.15)
    }
}
