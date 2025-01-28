import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
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
    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentQuestion()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        changeButtonsState(isEnabled: false)
        // Just pass correctAnswer because correct result is equal to the user's answer
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        changeButtonsState(isEnabled: false)
        // Pass inverted correctAnswer because correct result is opposite to the user's answer
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // Shows current question on the user's screen
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Converts mock QuizQuestion into QuizStepViewModel and calls show function
    private func showCurrentQuestion() {
        show(quiz: convert(model: currentQuestion))
    }
    
    // Changes image border color based on result
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers += isCorrect ? 1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showQuizResult(result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // Reset the game
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showCurrentQuestion()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
        changeButtonsState(isEnabled: true)
        imageView.layer.borderColor = UIColor.clear.cgColor
        if currentQuestionIndex == questions.count - 1 {
            // If the last question index is achieved then results are shown
            let quizResult = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат \(correctAnswers)/10",
                buttonText: "Сыграть еще раз"
            )
            showQuizResult(result: quizResult)
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    private func changeButtonsState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

// MARK: - Auxilary structs and ViewModels
struct ViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// "Question is shown" state model
struct QuizStepViewModel {
    // Film poster image
    let image: UIImage
    // Question about the film rating
    let question: String
    // Question order text (ex. "1/10")
    let questionNumber: String
}

// "Quiz results" state model
struct QuizResultsViewModel {
    // Alert title
    let title: String
    // Amount of correct answers
    let text: String
    // Alert button text
    let buttonText: String
}

struct QuizQuestion {
    // Film name, same as image name in the Assets
    let image: String
    // Film rating question
    let text: String
    let correctAnswer: Bool
}
