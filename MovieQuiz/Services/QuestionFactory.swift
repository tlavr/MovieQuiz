//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 29.1.2025.
//
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Private Properties
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private enum MovieError: LocalizedError {
        case imageLoadError
        case moviesDbError
        var errorDescription: String? {
            switch self {
            case .imageLoadError:   String(localized: "Невозможно загрузить данные", comment: "ImageLoadError")
            case .moviesDbError:   String(localized: "Невозможно загрузить данные", comment: "MoviesDbLoadError")
            }
        }
    }
    
    // MARK: - Public Methods
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Если массив пустой, значит база данных фильмов не была загружена и надо повторить попытку загрузки
            if self.movies.count == 0 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadData()
                    self.delegate?.didFailToLoadData(with: MovieError.moviesDbError)
                }
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                // Если не удалось загрузить картинку, значит соединение с сетью потеряно и необходимо повторить попытку
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: MovieError.imageLoadError)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let ratingThreshold = (7..<10).randomElement() ?? 0
            let questionSelectionThreshold = (0..<100).randomElement() ?? 0
            var text : String
            var correctAnswer : Bool
            if questionSelectionThreshold > 49 {
                text = "Рейтинг этого фильма больше чем \(ratingThreshold)?"
                correctAnswer = rating > Float(ratingThreshold)
            } else {
                text = "Рейтинг этого фильма меньше чем \(ratingThreshold)?"
                correctAnswer = rating < Float(ratingThreshold)
            }
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
