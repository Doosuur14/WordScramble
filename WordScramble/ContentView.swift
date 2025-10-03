//
//  ContentView.swift
//  WordScramble
//
//  Created by Faki Doosuur Doris on 18.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var scoreCount = 0
    
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
       // guard answer.count > 3 else {return}
        guard answer != rootWord else{return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
           
            return
        }
       // wordLength(word: answer)
       scoreCheck(word: answer)
        
        withAnimation{
            wordLength(word: answer)
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
   
    
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word" , text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
               
                
                Section{
                    ForEach(usedWords , id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).square")
                            Text(word)
                        }
                    }
                }
            }
            
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            
            .toolbar{
                Button("Restart" , action: startGame)
                    
                
            }
            .safeAreaInset(edge: .bottom){
                Text("Score: \(scoreCount)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.pink)
                    .foregroundColor(.white)
                    .font(.title)
                
                
            }
            
            
        }
    }
    
    
    func startGame(){
        scoreCount = 0
        usedWords = [String]()
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord  = allWords.randomElement() ?? "silkWorm"
               
                return
                
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    //to check if the word hasnt been used already
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    
    //to check if the word the user is trying to enter is possible.
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    
    //to check if the word is an english word
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func scoreCheck(word: String){
        if isReal(word: newWord) {
            scoreCount += 2
        }else {
            scoreCount -= 2
        }
    }
    
    func wordLength(word: String) {
        if word.count <= 3{
            scoreCount = 0
            wordError(title: "Three letter words are not allowed", message: "Try again, think outside the box.")
            
            
        }
        
        
    }
    
    
}
















struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
