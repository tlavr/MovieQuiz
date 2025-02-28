//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 1.2.2025.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
