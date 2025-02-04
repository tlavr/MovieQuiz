import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    // MARK: - Private Properties
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter

        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
                
        statisticService = StatisticService()
        statisticService?.setQuestionsAmount(to: questionsAmount)
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
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
            image: UIImage(named: model.image) ?? UIImage(),
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
        guard let alertPresenter = alertPresenter else {
            return
        }
        let endRoundAlert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else {return}
            // Reset the game
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showQuizResult(with: endRoundAlert)
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
            var roundResultText = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            roundResultText.append("Количество сыгранных квизов: \(statisticService.gamesCount)\n")
            roundResultText.append("Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date))\n")
            roundResultText.append("Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%")
            let quizResult = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: roundResultText,
                buttonText: "Сыграть еще раз"
            )
            showRoundResult(with: quizResult)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func changeButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        showCurrentQuestion()
    }
}
