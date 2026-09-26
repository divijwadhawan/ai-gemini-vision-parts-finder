//
//  CarPart.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 25.09.26.
//

import Foundation

struct CarPart: Codable, Identifiable {
    let id: Int
    let assemblyCode: String
    let name: String
    let description: String?
    let referenceNumber: String
    let calloutNumber: Int
    let quantity: Int
    let price: Double
    let imageIdentifier: String?
}
