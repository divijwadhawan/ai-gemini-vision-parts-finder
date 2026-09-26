//
//  AccessRequest.swift
//  GolfParts_iOS
//
//  Represents a user's request for access to the GolfParts API.
//

import Foundation


struct AccessRequest: Codable, Identifiable {

    let googleSub: String
    let email: String?
    let id: Int

    let requestedAt: String
    let reviewedAt: String?
    let reviewedBySub: String?

    let status: String
}
