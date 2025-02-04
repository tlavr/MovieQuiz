//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 29.1.2025.
//

class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Public Properties
    weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Private Properties
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 9?",
            correctAnswer: true), // real rating = 9.2
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 8?",
            correctAnswer: true), // real rating = 9
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 8?",
            correctAnswer: true), // real rating = 8.1
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true), // real rating = 8
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 7?",
            correctAnswer: true), // real rating = 8
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: true), // real rating = 6.6
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false), // real rating = 5.8
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 5?",
            correctAnswer: false), // real rating = 4.3
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 7?",
            correctAnswer: false), // real rating = 5.1
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false) // real rating = 5.8
    ]
    
    // MARK: - Public Methods
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
