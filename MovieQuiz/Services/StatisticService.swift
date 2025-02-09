//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 3.2.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    // MARK: - Public properties
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get { GameResult(
            correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
            total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
            date: storage.string(forKey: Keys.bestGameDate.rawValue) ?? Date().dateTimeString
        ) }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        // отношение всех правильных ответов от общего числа вопросов
        if gamesCount > 0 {
            return Double(100 * correctAnswers/(questionsAmount*gamesCount))
        } else {
            return 0
        }
    }
    
    // MARK: - Private properties
    private let storage: UserDefaults = .standard
    private var questionsAmount: Int = 10
    private var correctAnswers: Int {
        get { storage.integer(forKey: Keys.correctAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.correctAnswers.rawValue) }
    }
    private enum Keys: String {
        case correctAnswers
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }
    
    // MARK: - Public methods
    func store(_ gameResult: GameResult) {
        gamesCount += 1
        correctAnswers += gameResult.correct
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
    }
    
    func setQuestionsAmount(to newQuestionsAmount: Int) {
        questionsAmount = newQuestionsAmount
    }
}
