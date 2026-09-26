//
//  AccessAPIService.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 26.09.26.
//

//
//  AccessAPIService.swift
//  GolfParts_iOS
//
//  Handles access requests for normal users.
//
//  Flow:
//  1. User signs in with Google.
//  2. App checks GET /access-requests/me.
//  3. If NOT_REQUESTED, user can request access.
//  4. POST /access-requests creates the request.
//  5. Admin can approve or reject it.
//

import Foundation


// ============================================================
// MARK: - Access Status Response
// ============================================================
//
// Backend returns:
//
// {
//     "status": "APPROVED"
// }
//
// Possible values:
// NOT_REQUESTED
// PENDING
// APPROVED
// REJECTED
//

struct AccessStatusResponse: Codable {

    let status: String
}


// ============================================================
// MARK: - API Errors
// ============================================================

enum AccessAPIError: LocalizedError {

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


// ============================================================
// MARK: - Access API Service
// ============================================================

final class AccessAPIService {

    private let baseURL =
        "https://api.divijwadhawan.com"


    // ========================================================
    // MARK: - Check Current Access
    // ========================================================

    func getMyAccessStatus(
        idToken: String
    ) async throws -> AccessStatusResponse {

        guard let url = URL(
            string:
                "\(baseURL)/access-requests/me"
        ) else {

            throw AccessAPIError.invalidResponse
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
                AccessStatusResponse.self,
                from: data
            )
    }


    // ========================================================
    // MARK: - Request Access
    // ========================================================

    func requestAccess(
        idToken: String
    ) async throws -> AccessStatusResponse {

        guard let url = URL(
            string:
                "\(baseURL)/access-requests"
        ) else {

            throw AccessAPIError.invalidResponse
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


        let data =
            try await perform(
                request
            )


        return try JSONDecoder()
            .decode(
                AccessStatusResponse.self,
                from: data
            )
    }


    // ========================================================
    // MARK: - Shared HTTP Request
    // ========================================================

    private func perform(
        _ request: URLRequest
    ) async throws -> Data {

        let (data, response) =
            try await URLSession.shared
                .data(for: request)


        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw AccessAPIError.invalidResponse
        }


        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""


        // Safe to print.
        // We never print the Google ID token.
        print(
            "ACCESS API HTTP:",
            httpResponse.statusCode
        )

        print(
            "ACCESS API RESPONSE:",
            responseBody
        )


        guard (200...299)
            .contains(
                httpResponse.statusCode
            ) else {

            throw AccessAPIError.serverError(
                httpResponse.statusCode,
                responseBody
            )
        }


        return data
    }
}
