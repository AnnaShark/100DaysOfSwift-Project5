//
//  ViewController.swift
//  Project5
//
//  Created by Anna Shark on 26/8/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["sharks"]
        }
        startGame()

    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
                self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac,animated: true)
    }
    
    func submit (_ answer: String) {
        let lowAnswer = answer.lowercased()
        print("\(lowAnswer) from submit" )
        
        if isPossible(word: lowAnswer) {
            if isOriginal(word: lowAnswer) {
                if isReal(word: lowAnswer) {
                    usedWords.insert(lowAnswer, at: 0)
                    tableView.beginUpdates()
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    
                    return
                } else {
                    showErrorMessage(title: "Not recognised", message: "Word does not exist in English or is shorter than 3 letters")
                }
            } else {
                showErrorMessage(title: "Already used", message: "You cannot repeat words")
            }
        } else {
            showErrorMessage(title: "Impossible word", message: "Impossible to spell that word from \(title!.lowercased()). Repetition of the entire start word is not allowed")
        }
    }
    
    func isPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else {return false}
        print("\(word) from isPossible")
        
        if word == tempWord {
            return false
        }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
        
    }
    
    
    func isOriginal(word: String) -> Bool{
        print("\(word) from isOriginal")
        for item in usedWords {
            print(item)
        }
        return !usedWords.contains(word)    }
    
    func isReal(word: String) -> Bool{
        print("\(word) from isReal" )
        if word.count < 3 {
            return false
        } else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
        }
    }
    
    func showErrorMessage(title: String, message: String ) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac,animated: true)
        
    }


}

