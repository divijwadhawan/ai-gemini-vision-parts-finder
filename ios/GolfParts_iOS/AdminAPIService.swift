//
//  AdminAPIService.swift
//  GolfParts_iOS
//
//  Handles API calls used by the administrator.
//

import Foundation


enum AdminAPIError: LocalizedError {

    case invalidResponse
    case serverError(Int, String)

    var errorDescription: String? {

        switch self {

        case .invalidResponse:
            return "Invalid response from the GolfParts API."

        case .serverError(
            let statusCode,
            let message
        ):
            return "HTTP \(statusCode): \(message)"
        }
    }
}


final class AdminAPIService {

    private let baseURL =
        "https://api.divijwadhawan.com"


    // ============================================================
    // MARK: - Load Access Requests
    // ============================================================

    func getAccessRequests(
        idToken: String
    ) async throws -> [AccessRequest] {

        guard let url = URL(
            string:
                "\(baseURL)/admin/access-requests"
        ) else {

            throw AdminAPIError.invalidResponse
        }


        var request =
            URLRequest(url: url)

        request.httpMethod =
            "GET"

        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField:
                "Authorization"
        )


        let data =
            try await perform(
                request
            )


        return try JSONDecoder()
            .decode(
                [AccessRequest].self,
                from: data
            )
    }


    // ============================================================
    // MARK: - Approve User
    // ============================================================

    func approve(
        requestID: Int,
        idToken: String
    ) async throws {

        guard let url = URL(
            string:
                "\(baseURL)/admin/access-requests/\(requestID)/approve"
        ) else {

            throw AdminAPIError.invalidResponse
        }


        var request =
            URLRequest(url: url)

        request.httpMethod =
            "POST"

        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField:
                "Authorization"
        )


        _ = try await perform(
            request
        )
    }


    // ============================================================
    // MARK: - Reject User
    // ============================================================

    func reject(
        requestID: Int,
        idToken: String
    ) async throws {

        guard let url = URL(
            string:
                "\(baseURL)/admin/access-requests/\(requestID)/reject"
        ) else {

            throw AdminAPIError.invalidResponse
        }


        var request =
            URLRequest(url: url)

        request.httpMethod =
            "POST"

        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField:
                "Authorization"
        )


        _ = try await perform(
            request
        )
    }


    // ============================================================
    // MARK: - Shared HTTP Request
    // ============================================================

    private func perform(
        _ request: URLRequest
    ) async throws -> Data {

        let (data, response) =
            try await URLSession.shared
                .data(for: request)


        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw AdminAPIError.invalidResponse
        }


        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""


        print(
            "ADMIN API HTTP:",
            httpResponse.statusCode
        )

        print(
            "ADMIN API RESPONSE:",
            responseBody
        )


        guard (200...299)
            .contains(
                httpResponse.statusCode
            ) else {

            throw AdminAPIError.serverError(
                httpResponse.statusCode,
                responseBody
            )
        }


        return data
    }
}
