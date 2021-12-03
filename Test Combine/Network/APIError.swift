//
//  APIError.swift
//  Test Combine
//
//  Created by Koussaïla Ben Mamar on 01/11/2021.
//

import Foundation

enum APIError: String, Error {
    case notFound = "Error 404"
    case invalidURL = "Error: Invalid URL"
    case decodeError = "Decoding error"
    case networkError = "Network error"
    case failed = "An error has occured"
}
