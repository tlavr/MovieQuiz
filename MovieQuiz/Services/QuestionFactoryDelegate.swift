//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 1.2.2025.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
