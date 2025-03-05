//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 5.3.2025.
//
import UIKit

final class MovieQuizPresenter {
    // MARK: - Public Properties
    let questionsAmount: Int = 10

    // MARK: - Private Properties
    private var currentQuestionIndex: Int = .zero
    
    // MARK: - Public Methods
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = .zero
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
