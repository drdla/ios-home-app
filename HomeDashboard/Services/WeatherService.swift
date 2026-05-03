import Foundation
import CoreLocation

// Fetches current + tomorrow weather from Open-Meteo (no API key required).
// Home location: Dachau, Bavaria (48.2600 N, 11.4342 E)

struct WeatherService {
    var fetch: () async throws -> WeatherSnapshot

    static let live = WeatherService {
        let settings = AppSettings.shared
        let lat = settings.homeLat
        let lon = settings.homeLon

        let url = URL(string:
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=\(lat)&longitude=\(lon)" +
            "&current=temperature_2m,precipitation_probability" +
            "&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode" +
            "&hourly=temperature_2m,precipitation_probability" +
            "&forecast_days=2" +
            "&timezone=Europe%2FBerlin"
        )!

        let (data, _) = try await URLSession.shared.data(from: url)
        return try WeatherResponseParser.parse(data)
    }

    static let mock = WeatherService {
        DashboardSnapshot.mockup.weather
    }
}

// MARK: - Response parser

enum WeatherResponseParser {
    struct Response: Decodable {
        struct Current: Decodable {
            let temperature_2m: Double
            let precipitation_probability: Int?
        }
        struct Daily: Decodable {
            let temperature_2m_max: [Double]
            let temperature_2m_min: [Double]
            let precipitation_probability_max: [Int?]
            let weathercode: [Int]
        }
        struct Hourly: Decodable {
            let temperature_2m: [Double]
            let precipitation_probability: [Int?]
        }
        let current: Current
        let daily: Daily
        let hourly: Hourly
    }

    static func parse(_ data: Data) throws -> WeatherSnapshot {
        let r = try JSONDecoder().decode(Response.self, from: data)
        let todayCode   = r.daily.weathercode.first ?? 0
        let tomorrowMax = r.daily.temperature_2m_max.dropFirst().first ?? 0
        let tomorrowMin = r.daily.temperature_2m_min.dropFirst().first ?? 0

        // Open-Meteo returns 48 hourly values (2 days). Take the first 24 for today.
        let hourlyTemps  = Array(r.hourly.temperature_2m.prefix(24))
        let hourlyPrecip = Array(r.hourly.precipitation_probability.prefix(24)).map { $0 ?? 0 }

        return WeatherSnapshot(
            currentTemperatureCelsius:  Int(r.current.temperature_2m.rounded()),
            currentLowCelsius:          Int((r.daily.temperature_2m_min.first ?? 0).rounded()),
            tomorrowHighCelsius:        Int(tomorrowMax.rounded()),
            tomorrowLowCelsius:         Int(tomorrowMin.rounded()),
            precipitationChancePercent: r.current.precipitation_probability ?? 0,
            condition: condition(from: todayCode),
            hourlyTemperatures: hourlyTemps,
            hourlyPrecipitationChances: hourlyPrecip
        )
    }

    private static func condition(from wmoCode: Int) -> WeatherCondition {
        switch wmoCode {
        case 0, 1:           return .sunny
        case 95, 96, 99:     return .storm
        default:             return .cloudy
        }
    }
}
