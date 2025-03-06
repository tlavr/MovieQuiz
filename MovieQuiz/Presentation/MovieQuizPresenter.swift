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
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol?
    weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Public Methods
    init(viewController: MovieQuizViewControllerProtocol?) {
        guard let viewController else { return }
        self.viewController = viewController
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        self.questionFactory?.loadData()
       
        let statisticService = StatisticService()
        statisticService.setQuestionsAmount(to: questionsAmount)
        self.statisticService = statisticService
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        viewController?.changeButtonsState(isEnabled: false)
        // Pass inverted correctAnswer in case of NoButton because correct result is opposite to the user's answer
        var isCorrect: Bool
        if isYes { isCorrect = currentQuestion.correctAnswer }
        else { isCorrect = !currentQuestion.correctAnswer }
        correctAnswers += isCorrect ? 1 : 0
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func showCurrentQuestion() {
        guard let currentQuestion else { return }
        let viewModel = convert(model: currentQuestion)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func reset() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {
        viewController?.changeButtonsState(isEnabled: true)
        viewController?.hideImageBorder()
        if isLastQuestion() {
            guard let statisticService else {return}
            let roundResult = GameResult(
                correct: correctAnswers,
                total: questionsAmount,
                date: Date().dateTimeString
            )
            statisticService.store(roundResult)
            let roundResultText = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let quizResult = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: roundResultText,
                buttonText: "Сыграть еще раз"
            )
            prepareRoundResult(with: quizResult)
        } else {
            viewController?.showLoadingIndicator()
            switchToNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            showNextQuestionOrResults()
        }
    }
    
    private func prepareRoundResult(with result: QuizResultsViewModel) {
        let endRoundAlert = AlertModel(
            identifier: "Game results",
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            self.reset()
        }
        viewController?.showAlert(with: endRoundAlert)
    }
    
    private func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        let networkErrorAlert = AlertModel(identifier: "Network error",
                                           title: "Что-то пошло не так(",
                                           message: message,
                                           buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.reset()
        }
        viewController?.showAlert(with: networkErrorAlert)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
        currentQuestion = question
        viewController?.hideLoadingIndicator()
        showCurrentQuestion()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
}

