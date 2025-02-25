//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 23.2.2025.
//
import Foundation

/// Отвечает за загрузку данных по URL
struct NetworkClient {
    private enum NetworkError: LocalizedError {
        case codeError
        case sessionError
        var errorDescription: String? {
            switch self {
            case .codeError:   String(localized: "Невозможно загрузить данные", comment: "UrlCodeError")
            case .sessionError:   String(localized: "Невозможно загрузить данные", comment: "UrlSessionError")
            }
        }
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(NetworkError.sessionError))
                return
            }
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
