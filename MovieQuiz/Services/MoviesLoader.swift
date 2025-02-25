//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 23.2.2025.
//

import Foundation

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    private enum JsonError: LocalizedError {
        case decoderError
        var errorDescription: String? {
            switch self {
            case .decoderError:   String(localized: "Невозможно загрузить данные", comment: "JsonDecoderError")
            }
        }
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    // MARK: - Public methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(JsonError.decoderError))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
