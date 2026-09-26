//
//  PartsAPIService.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 25.09.26.
//

import Foundation

enum PartsAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."

        case .invalidResponse:
            return "Invalid response from the GolfParts API."

        case .serverError(let code, let message):
            return "HTTP \(code): \(message)"
        }
    }
}

final class PartsAPIService {

    private let baseURL =
        "https://api.divijwadhawan.com"

    func getParts(
        assemblyCode: String,
        idToken: String
    ) async throws -> [CarPart] {

        guard let url = URL(
            string:
                "\(baseURL)/assemblies/\(assemblyCode)/parts"
        ) else {
            throw PartsAPIError.invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw PartsAPIError.invalidResponse
        }

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            let message =
                String(
                    data: data,
                    encoding: .utf8
                ) ?? ""

            throw PartsAPIError.serverError(
                httpResponse.statusCode,
                message
            )
        }

        return try JSONDecoder().decode(
            [CarPart].self,
            from: data
        )
    }
}
