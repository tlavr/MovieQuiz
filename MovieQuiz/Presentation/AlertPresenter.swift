//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 1.2.2025.
//
import UIKit

class AlertPresenter {
    // MARK: - Public properties
    weak var delegate: MovieQuizViewController?
    
    // MARK: - Public Methods
    func showQuizResult(with alertInfo: AlertModel) {
        let alert = UIAlertController(
            title: alertInfo.title,
            message: alertInfo.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: alertInfo.buttonText, style: .default) { _ in
            alertInfo.completion()
        }
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
