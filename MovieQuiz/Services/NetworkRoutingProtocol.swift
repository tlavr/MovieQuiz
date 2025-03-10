//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by Timur Lavrukhin on 28.2.2025.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
