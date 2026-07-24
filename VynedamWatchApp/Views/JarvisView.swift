import SwiftUI

struct JarvisView: View {
    @EnvironmentObject var jarvisService: JarvisService
    @State private var customPrompt: String = ""
    
    var body: some View {
        VStack(spacing: 4) {
            // Header with domain icon image and Ollama indicator
            HStack(spacing: 6) {
                Image(jarvisService.selectedDomain.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(jarvisService.selectedDomain.themeColor, lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(jarvisService.selectedDomain.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 3) {
                        Circle()
                            .fill(jarvisService.isOllamaAvailable ? Color.green : Color.orange)
                            .frame(width: 5, height: 5)
                        Text(jarvisService.isOllamaAvailable ? "Ollama (\(jarvisService.ollamaModel))" : "Ollama (Offline)")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            
            ScrollView {
                VStack(spacing: 6) {
                    // Response Panel
                    if jarvisService.isStreaming || !jarvisService.responseStream.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("OLLAMA LLM")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(jarvisService.selectedDomain.themeColor)
                                Spacer()
                                if jarvisService.isStreaming {
                                    HStack(spacing: 2) {
                                        Circle().fill(jarvisService.selectedDomain.themeColor).frame(width: 3, height: 3)
                                        Circle().fill(jarvisService.selectedDomain.themeColor).frame(width: 3, height: 3)
                                        Circle().fill(jarvisService.selectedDomain.themeColor).frame(width: 3, height: 3)
                                    }
                                }
                            }
                            
                            Text(jarvisService.responseStream)
                                .font(.system(size: 11))
                                .lineSpacing(1.5)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(8)
                        .background(jarvisService.selectedDomain.themeColor.opacity(0.12))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(jarvisService.selectedDomain.themeColor.opacity(0.3), lineWidth: 1.0)
                        )
                    } else {
                        // Introduction
                        Text("Type your prompt or pick a suggestion below to query local Ollama LLM.")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    }
                    
                    // Input field (dictation / keyboard on watchOS)
                    TextField("Ask Ollama...", text: $customPrompt) {
                        if !customPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            submitPrompt(customPrompt)
                        }
                    }
                    .font(.system(size: 11))
                    .padding(.vertical, 2)
                    
                    // Suggestions Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Suggested Queries")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.leading, 2)
                        
                        ForEach(suggestionsForCurrentDomain(), id: \.self) { suggestion in
                            Button(action: {
                                submitPrompt(suggestion)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 9))
                                        .foregroundColor(jarvisService.selectedDomain.themeColor)
                                    Text(suggestion)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.85))
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func submitPrompt(_ prompt: String) {
        customPrompt = ""
        jarvisService.queryLLM(prompt: prompt)
        playTapHaptic()
    }
    
    private func suggestionsForCurrentDomain() -> [String] {
        switch jarvisService.selectedDomain {
        case .safeguard:
            return [
                "What should I do in a safety emergency?",
                "How can I share my live GPS location?"
            ]
        case .prescripto:
            return [
                "Is my current heart rate stable?",
                "Should I seek immediate medical care?"
            ]
        case .learning:
            return [
                "Explain Database Indexing in short.",
                "How does REST compare to GraphQL?"
            ]
        case .agrogen:
            return [
                "What crop tasks are optimal for 29°C?",
                "Irrigation advice for basmati rice."
            ]
        case .lawgen:
            return [
                "What basic rights do I have during arrest?",
                "What does Section 50 of CrPC state?"
            ]
        case .jarvis:
            return [
                "Hello JARVIS, run a system diagnosis.",
                "What is my upcoming schedule today?"
            ]
        }
    }
    
    private func playTapHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}
