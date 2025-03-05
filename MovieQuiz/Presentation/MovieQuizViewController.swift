import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = .zero
    private var currentQuestionIndex: Int = .zero
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        self.questionFactory?.loadData()
        
        statisticService = StatisticService()
        statisticService?.setQuestionsAmount(to: questionsAmount)
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        changeButtonsState(isEnabled: false)
        // Just pass correctAnswer because correct result is equal to the user's answer
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        changeButtonsState(isEnabled: false)
        // Pass inverted correctAnswer because correct result is opposite to the user's answer
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // Shows current question on the user's screen
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Converts QuizQuestion into QuizStepViewModel and calls show function
    private func showCurrentQuestion() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let viewModel = convert(model: currentQuestion)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // Changes image border color based on result
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers += isCorrect ? 1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    private func showRoundResult(with result: QuizResultsViewModel) {
        guard let alertPresenter = alertPresenter else { return }
        let endRoundAlert = AlertModel(
            identifier: "Game results",
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }
            // Reset the game
            self.currentQuestionIndex = .zero
            self.correctAnswers = .zero
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showAlert(with: endRoundAlert)
    }
    
    private func showNextQuestionOrResults() {
        changeButtonsState(isEnabled: true)
        imageView.layer.borderColor = UIColor.clear.cgColor
        if currentQuestionIndex == questionsAmount - 1 {
            // If the last question index is achieved then results are shown
            guard let statisticService = statisticService else {return}
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
            showRoundResult(with: quizResult)
        } else {
            currentQuestionIndex += 1
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func changeButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        guard let alertPresenter = alertPresenter else { return }
        let networkErrorAlert = AlertModel(identifier: "Network error",
                                           title: "Что-то пошло не так(",
                                           message: message,
                                           buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = .zero
            self.correctAnswers = .zero
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showAlert(with: networkErrorAlert)
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        hideLoadingIndicator()
        showCurrentQuestion()
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showLoadingIndicator()
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}
