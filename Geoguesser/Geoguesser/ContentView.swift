//
//  ContentView.swift
//  Geoguesser
//
//  Created by Devin KARADAĞ on 11.03.2023.
//



import SwiftUI

struct ShuffledImage: View {
    let gridSize: Int = 4
    @Binding var roundNumber: Int
    @State private var shuffledSections: [UIImage] = []

    private var imageName: String {
        switch roundNumber {
        case 0:
            return "ankara"
        case 1:
            return "istanbul"
        case 2:
            return "izmir"
        case 3:
            return "bursa"
        case 4:
            return "antalya"
        default:
            return ""
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 1) {
            if !shuffledSections.isEmpty {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(alignment: .center, spacing: 1) {
                        ForEach(0..<gridSize, id: \.self) { column in
                            Image(uiImage: shuffledSections[row * gridSize + column])
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
        }
        .onAppear {
            updateShuffledSections()
        }
        .onChange(of: roundNumber) { _ in
            updateShuffledSections()
        }
    }

    private func updateShuffledSections() {
        if let image = UIImage(named: imageName) {
            let sections = divideImageIntoSections(image: image)
            shuffledSections = sections.shuffled()
        }
    }

    private func divideImageIntoSections(image: UIImage) -> [UIImage] {
        let size = CGSize(width: image.size.width / CGFloat(gridSize), height: image.size.height / CGFloat(gridSize))
        var sections: [UIImage] = []

        for row in 0..<gridSize {
            for column in 0..<gridSize {
                let rect = CGRect(x: size.width * CGFloat(column), y: size.height * CGFloat(row), width: size.width, height: size.height)
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    sections.append(UIImage(cgImage: cgImage))
                }
            }
        }
        return sections
    }
}


struct ContentView: View {
    let words = ["ankara", "istanbul", "izmir", "bursa", "antalya"]
    @State private var currentRound = 0
    @State private var correctAnswer = ""
    @State private var guessedLetters: Set<Character> = []
    @State private var helpCount = 0
    @State private var currentScore = 0
    @State private var userInput: String = ""
    @State private var guessedCorrectly: Bool?
    @State private var gameState: GameState = .playing
    @State private var errorText: String?  
    
    enum GameState {
            case playing, gameOver
        }

    
    
    var maskedAnswer: String {
        var result = ""
        for char in correctAnswer {
            if guessedLetters.contains(char) {
                result.append(char)
            } else {
                result.append("_")
            }
        }
        return result
    }
    
    var displayedAnswer: String {
        var result = ""
        for char in maskedAnswer {
            result.append(char)
            result.append(" ")
        }
        return result
    }
    
    
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            if gameState == .playing {
                           VStack {
                
                
                
                
                Text("GeoGuesser")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                Text("Round \(currentRound + 1)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                ShuffledImage(roundNumber: $currentRound) 
                                   .padding()
                                   .background(Color.black.opacity(0.7))
                                   .cornerRadius(10)
                
                Text(displayedAnswer)
                    .font(.system(size: 30, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                if let guessedCorrectly = guessedCorrectly {
                    Text(guessedCorrectly ? "Congrats!" : "Nice try!")
                        .foregroundColor(guessedCorrectly ? .green : .red)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                
                TextField("Guess a letter", text: $userInput, onCommit: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        handleLetterGuess(userInput)
                        userInput = ""
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 150, height: 50)
                .padding()
                .onReceive(userInput.publisher.collect()) { newValue in
                    userInput = String(newValue.prefix(1))
                }
                
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        useHelp(maxHelp: 5)
                    }
                }) {
                    Text("Help")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding()
                               
                if let errorText = errorText {
                 Text(errorText)
                        .foregroundColor(.red)
                        .padding()
                               }
                
                
                Text("Score: \(currentScore)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            } else if gameState == .gameOver {
                          VStack {
                              Text("Congrats!")
                                  .font(.largeTitle)
                                  .fontWeight(.bold)
                                  .foregroundColor(.white)
                              
                              Text("You got \(currentScore) points")
                                  .font(.title2)
                                  .fontWeight(.bold)
                                  .foregroundColor(.white)
                                  .padding()
                              
                              Button(action: {
                                  withAnimation(.easeInOut(duration: 0.3)) {
                                      newGame()
                                  }
                              }) {
                                  Text("New Game")
                                      .fontWeight(.bold)
                                      .foregroundColor(.white)
                                      .padding()
                                      .background(Color.black.opacity(0.7))
                                      .cornerRadius(10)
                              }
                              .padding()
                          }
                      }
                  }
        .onAppear {
            correctAnswer = words[currentRound]
        }
    }
    
    
    
    private func handleLetterGuess(_ letter: String) {
        guard let guessedLetter = letter.last?.lowercased() else { return }
        
        if !guessedLetters.contains(Character(guessedLetter)) {
            guessedLetters.insert(Character(guessedLetter))
            if !correctAnswer.contains(guessedLetter) {
                if helpCount < correctAnswer.count - 1 {
                    helpCount += 1
                }
                guessedCorrectly = false
            } else {
                guessedCorrectly = true
            }
            if maskedAnswer == correctAnswer {
                currentScore += (100 - helpCount * 10)
                nextRound()
            }
        }
        userInput = ""
    }
    
    
    private func useHelp(maxHelp: Int) {
        if helpCount < correctAnswer.count && helpCount < maxHelp {
            var unguessedChars: [Character] = []

            for char in correctAnswer {
                if !guessedLetters.contains(char) {
                    unguessedChars.append(char)
                }
            }
            if !unguessedChars.isEmpty {
                let randomIndex = Int.random(in: 0..<unguessedChars.count)
                let randomChar = unguessedChars[randomIndex]
                guessedLetters.insert(randomChar)
                helpCount += 1
                if maskedAnswer == correctAnswer {
                    currentScore += (100 - helpCount * 10)
                    nextRound()
                }
            } else {
                errorText = "No unguessed characters left."
            }
        } else {
            errorText = "Max number of help is reached."
        }
    }

    
    private func nextRound() {
        if currentRound < words.count - 1 {
            currentRound += 1
            correctAnswer = words[currentRound]
            guessedLetters.removeAll()
            helpCount = 0
            guessedCorrectly = nil
        } else {
            gameState = .gameOver
        }
    }
    
    
    private func gameOver() -> Alert {
        let message = "Game Over!\nFinal Score: \(currentScore)"
        return Alert(title: Text(message),
                     dismissButton: .default(Text("New Game")) {
            newGame()
        })
    }
    
    private func newGame() {
        currentRound = 0
        currentScore = 0
        correctAnswer = words[currentRound]
        guessedLetters.removeAll()
        helpCount = 0
        guessedCorrectly = nil
        gameState = .playing

    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
