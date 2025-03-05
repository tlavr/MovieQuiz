//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 1.2.2025.
//
import UIKit

final class AlertPresenter {
    // MARK: - Public properties
    weak var delegate: MovieQuizViewController?
    
    // MARK: - Public Methods
    func showAlert(with alertInfo: AlertModel) {
        let alert = UIAlertController(
            title: alertInfo.title,
            message: alertInfo.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = alertInfo.identifier
        let action = UIAlertAction(title: alertInfo.buttonText, style: .default) { _ in
            alertInfo.completion()
        }
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
