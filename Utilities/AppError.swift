//
//  AppError.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import Foundation

enum AppError: Error, LocalizedError {
    case notAuthenticated
    case notAuthorized
    case notFound
    case invalidData
    case networkError
    case serverError
    case invalidOperation(message: String)
    case paymentError(message: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You need to be logged in to perform this action."
        case .notAuthorized:
            return "You are not authorized to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .invalidData:
            return "The data provided is invalid or incomplete."
        case .networkError:
            return "A network error occurred. Please check your connection."
        case .serverError:
            return "A server error occurred. Please try again later."
        case .invalidOperation(let message):
            return message
        case .paymentError(let message):
            return message
        case .unknown:
            return "An unknown error occurred."
        }
    }
} 