//
//  BackendStatusService.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 26.09.26.
//

import Foundation

final class BackendStatusService {

    private let healthURL =
        URL(string: "https://api.divijwadhawan.com/health")!

    func waitUntilAvailable() async -> Bool {

        // Try for roughly 90 seconds.
        for _ in 1...18 {

            do {
                var request = URLRequest(url: healthURL)
                request.timeoutInterval = 10

                let (_, response) =
                    try await URLSession.shared.data(
                        for: request
                    )

                if let httpResponse =
                    response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {

                    return true
                }

            } catch {
                // Render may still be waking up.
            }

            try? await Task.sleep(
                for: .seconds(5)
            )
        }

        return false
    }
}
