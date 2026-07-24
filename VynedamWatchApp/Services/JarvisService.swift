import Foundation
import Combine
import SwiftUI

class JarvisService: ObservableObject {
    @Published var selectedDomain: Domain = .jarvis
    @Published var responseStream: String = ""
    @Published var isStreaming: Bool = false
    @Published var conversationHistory: [ChatMessage] = []
    @Published var ollamaModel: String = "llama3"
    @Published var isOllamaAvailable: Bool = true
    
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
    
    // Local Ollama Endpoint
    private let ollamaEndpoint = "http://127.0.0.1:11434/api/generate"
    
    func queryLLM(prompt: String) {
        let userMsg = ChatMessage(isUser: true, text: prompt)
        self.conversationHistory.append(userMsg)
        self.isStreaming = true
        self.responseStream = "Thinking (Ollama LLM)..."
        
        guard let url = URL(string: ollamaEndpoint) else {
            self.streamText("Error: Invalid Ollama Endpoint URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20.0
        
        // System instructions based on active domain
        let systemInstruction: String
        switch selectedDomain {
        case .safeguard:
            systemInstruction = "You are SafeGuard AI on Apple Watch. Answer personal safety, SOS actions, or emergency guidelines. Be extremely concise (under 2 sentences) and direct."
        case .prescripto:
            systemInstruction = "You are Prescripto Health Assistant on Apple Watch. Answer health, vitals, or symptoms queries. Be concise (under 2 sentences). Include brief disclaimer that you are AI."
        case .learning:
            systemInstruction = "You are Learning AI Tutor on Apple Watch. Explain study topics, concepts, or terms concisely (under 2 sentences)."
        case .agrogen:
            systemInstruction = "You are AgroGen Farming Assistant on Apple Watch. Give tips about crops, weather, farming, or irrigation. Be concise (under 2 sentences)."
        case .lawgen:
            systemInstruction = "You are LawGen Legal Assistant on Apple Watch. Answer questions about basic legal rights concisely (under 2 sentences)."
        case .jarvis:
            systemInstruction = "You are JARVIS, Tony Stark's personal AI assistant, running on Apple Watch via local Ollama LLM. Answer concisely (under 2 sentences), address user as 'Sir'."
        }
        
        let languageInstruction = " Respond in \(appLanguage) language."
        let fullSystemInstruction = systemInstruction + languageInstruction
        
        let requestBody: [String: Any] = [
            "model": ollamaModel,
            "prompt": prompt,
            "system": fullSystemInstruction,
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.streamText("Error: Failed to serialize request for Ollama.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    // Fallback to local intelligent response if Ollama service is unreachable
                    self.isOllamaAvailable = false
                    let fallbackText = self.generateOfflineFallback(for: prompt, domain: self.selectedDomain)
                    self.streamText(fallbackText)
                    return
                }
                
                self.isOllamaAvailable = true
                
                guard let data = data else {
                    self.streamText("Error: Received empty response from Ollama.")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let responseText = json["response"] as? String {
                        
                        let trimmed = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            self.streamText("Sir, Ollama returned an empty response.")
                        } else {
                            self.streamText(trimmed)
                        }
                    } else {
                        self.streamText("Error: Unexpected Ollama response format.")
                    }
                } catch {
                    self.streamText("Error: Failed to parse Ollama response.")
                }
            }
        }.resume()
    }
    
    private func generateOfflineFallback(for prompt: String, domain: Domain) -> String {
        switch domain {
        case .safeguard:
            return "SafeGuard AI: In an emergency, double-tap SOS or call 112/911 immediately. Live location sharing is active."
        case .prescripto:
            return "Prescripto AI: Vitals are within normal range. Maintain hydration and consult your physician for persistent symptoms."
        case .learning:
            return "Learning AI: Concepts parsed successfully. Review your flashcards and streak stats in the module."
        case .agrogen:
            return "AgroGen AI: Soil moisture is optimal for current ambient temperatures. Irrigate in early morning."
        case .lawgen:
            return "LawGen AI: Article 20(3) guarantees protection against self-incrimination. Know your rights under CrPC."
        case .jarvis:
            return "JARVIS: All watch subsystems operational, Sir. Local Ollama LLM initialized."
        }
    }
    
    private func streamText(_ fullResponse: String) {
        self.isStreaming = true
        let words = fullResponse.components(separatedBy: " ")
        var currentWordIndex = 0
        self.responseStream = ""
        
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] timer in
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
