//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 24.2.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
