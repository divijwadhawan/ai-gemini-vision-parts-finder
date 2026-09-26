import Foundation

struct ScanResult: Codable {
    let assemblyCode: String
    let confidence: Double
    let boundingBox: BoundingBox
}

struct BoundingBox: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}//
//  ScanModels.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 25.09.26.
//

