//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 29.1.2025.
//

import UIKit

// "Question is shown" state model
struct QuizStepViewModel {
    // Film poster image
    let image: UIImage
    // Question about the film rating
    let question: String
    // Question order text (ex. "1/10")
    let questionNumber: String
}
