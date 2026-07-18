import SwiftUI

struct LearningView: View {
    @EnvironmentObject var jarvisService: JarvisService
    @State private var flashcardIndex: Int = 0
    @State private var quizIndex: Int = 0
    @State private var selectedAnswer: Int? = nil
    @State private var quizCompleted: Bool = false
    @State private var showQuizFeedback: Bool = false
    @State private var isAnswerCorrect: Bool = false
    
    // Mock Study Flashcards
    let flashcards = [
        ("Database Indexing", "A data structure technique to quickly look up and retrieve data without scanning every row in a table. Employs B-Trees or Hash indexes."),
        ("Git Rebasing", "Reapply commits on top of another base tip. Ideal for clean, linear histories, but should never be used on shared public branches."),
        ("REST vs GraphQL", "REST exposes unique endpoints per resource. GraphQL uses a single endpoint allowing client-defined queries to prevent over-fetching.")
    ]
    
    // Mock Quiz Questions
    struct Question {
        let text: String
        let options: [String]
        let correctIndex: Int
    }
    
    let quizQuestions = [
        Question(
            text: "Which protocol is stateless?",
            options: ["1. TCP", "2. HTTP", "3. WebSocket"],
            correctIndex: 1
        ),
        Question(
            text: "What does DNS translate?",
            options: ["1. IPs to Names", "2. Names to IPs", "3. Files to Bytes"],
            correctIndex: 1
        ),
        Question(
            text: "Which is a NoSQL database?",
            options: ["1. PostgreSQL", "2. MySQL", "3. MongoDB"],
            correctIndex: 2
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(Color(red: 0.18, green: 0.5, blue: 0.98))
                    Text("Learning")
                        .font(.headline)
                }
                
                // Progress & Streak Card
                HStack(spacing: 12) {
                    // Circular Progress Ring
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.15), lineWidth: 5)
                            .frame(width: 36, height: 36)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(jarvisService.dailyGoalProgress))
                            .stroke(
                                Color(red: 0.18, green: 0.5, blue: 0.98),
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(jarvisService.dailyGoalProgress * 100))%")
                            .font(.system(size: 8, weight: .bold))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("DAILY STREAK")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(jarvisService.learningStreak) Days active")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    Spacer()
                }
                .padding(8)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)
                
                // Flashcards Carousel Widget
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Flashcards")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(flashcards[flashcardIndex].0)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(flashcardIndex+1)/\(flashcards.count)")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                        
                        Text(flashcards[flashcardIndex].1)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            Button(action: {
                                if flashcardIndex > 0 {
                                    flashcardIndex -= 1
                                    playClickHaptic()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .disabled(flashcardIndex == 0)
                            
                            Spacer()
                            
                            Button(action: {
                                if flashcardIndex < flashcards.count - 1 {
                                    flashcardIndex += 1
                                    playClickHaptic()
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .disabled(flashcardIndex == flashcards.count - 1)
                        }
                        .padding(.top, 2)
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Micro 3-Question Quiz
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Quiz")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 4)
                    
                    if !quizCompleted {
                        let activeQuestion = quizQuestions[quizIndex]
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activeQuestion.text)
                                .font(.system(size: 10, weight: .semibold))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            ForEach(0..<activeQuestion.options.count, id: \.self) { idx in
                                Button(action: {
                                    submitAnswer(idx)
                                }) {
                                    Text(activeQuestion.options[idx])
                                        .font(.system(size: 9))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(5)
                                        .background(
                                            selectedAnswer == idx ?
                                            (idx == activeQuestion.correctIndex ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                            : Color.white.opacity(0.08)
                                        )
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                                .disabled(selectedAnswer != nil)
                            }
                            
                            if showQuizFeedback {
                                Text(isAnswerCorrect ? "Correct!" : "Incorrect. Try next!")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(isAnswerCorrect ? .green : .red)
                                    .padding(.top, 2)
                                
                                Button(action: {
                                    advanceQuiz()
                                }) {
                                    Text("Next Question")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                        .background(Color.white)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.headline)
                            Text("Quiz Completed!")
                                .font(.system(size: 11, weight: .bold))
                            Text("+10 XP Added to your profile")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                resetQuiz()
                            }) {
                                Text("RETRY QUIZ")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func submitAnswer(_ idx: Int) {
        selectedAnswer = idx
        let correct = idx == quizQuestions[quizIndex].correctIndex
        isAnswerCorrect = correct
        showQuizFeedback = true
        
        if correct {
            playCorrectHaptic()
            jarvisService.incrementStreak()
        } else {
            playWrongHaptic()
        }
    }
    
    private func advanceQuiz() {
        selectedAnswer = nil
        showQuizFeedback = false
        if quizIndex < quizQuestions.count - 1 {
            quizIndex += 1
        } else {
            quizCompleted = true
        }
    }
    
    private func resetQuiz() {
        quizIndex = 0
        selectedAnswer = nil
        showQuizFeedback = false
        quizCompleted = false
    }
    
    private func playClickHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
    
    private func playCorrectHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
    
    private func playWrongHaptic() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.failure)
        #endif
    }
}
