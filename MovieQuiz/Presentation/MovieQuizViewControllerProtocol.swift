//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 6.3.2025.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrect: Bool)
    func hideImageBorder()
    func changeButtonsState(isEnabled: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showAlert(with alert: AlertModel)
}
