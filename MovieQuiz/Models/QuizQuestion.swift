//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 29.1.2025.
//
import Foundation

struct QuizQuestion {
    // Film name, same as image name in the Assets
    let imageData: Data
    // Film rating question
    let text: String
    let correctAnswer: Bool
}
