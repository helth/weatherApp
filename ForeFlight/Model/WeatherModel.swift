//
//  WeatherModel.swift
//  ForeFlight
//
//  Created by Frederik Helth on 24/01/2024.
//

import Foundation

struct WeatherModel: Codable {
    let report: Report

    struct Report: Codable {
        let conditions: Conditions
        let forecast: Forecast

        struct Conditions: Codable {
            let text: String
            let ident: String
            let dateIssued: String
            let lat: Double
            let lon: Double
            let elevationFt: Double
            let tempC: Double
            let dewpointC: Double
            let pressureHg: Double
            let pressureHpa: Double
            let reportedAsHpa: Bool
            let densityAltitudeFt: Int
            let relativeHumidity: Int
            let flightRules: String
            let cloudLayers: [CloudLayer]
            let cloudLayersV2: [CloudLayer]
            let weather: [String]
            let visibility: Visibility
            let wind: Wind
        }

        struct CloudLayer: Codable {
            let coverage: String
            let altitudeFt: Double
            let ceiling: Bool
        }

        struct Visibility: Codable {
            let distanceSm: Double
            let prevailingVisSm: Double
        }

        struct Wind: Codable {
            let speedKts: Double
            let direction: Int
            let from: Int
            let variable: Bool
        }
        
        struct Remarks: Codable {
            let precipitationDiscriminator: Bool
        }
        
        // Forecast
        struct Forecast: Codable {
            let text: String
            let ident: String
            let dateIssued: String
            let lat: Double
            let lon: Double
            let elevationFt: Double
        }
        
    }
}
