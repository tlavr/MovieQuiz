//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 3.2.2025.
//

struct GameResult {
    let correct: Int
    let total: Int
    let date: String
    
    // Метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
