//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 3.2.2025.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(_ gameResult: GameResult)
    func setQuestionsAmount(to newQuestionsAmount: Int)
}
