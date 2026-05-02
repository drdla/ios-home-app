import Foundation

// Fetches real-time S-Bahn departures from the MVG v3 JSON API.
// Station: Dachau Stadt  global ID: de:09174:6850
//
// Endpoint: https://www.mvg.de/api/bgw-pt/v3/departures
// The old fahrinfo endpoint is no longer available.

struct TransitService {
    var fetchStops: () async throws -> [TransitStopGroup]

    static let live = TransitService {
        let settings = AppSettings.shared
        let limit     = max(settings.transitDepartureLimit, 20)  // fetch enough to include both directions

        let stops = [
            ("Dachau Stadt", "de:09174:6850"),
            ("Dachau Bahnhof", "de:09174:6800")
        ]

        return try await withThrowingTaskGroup(of: TransitStopGroup.self) { group in
            for stop in stops {
                group.addTask {
                    let departures = try await fetchDepartures(stationId: stop.1, limit: limit)
                    return TransitStopGroup(
                        name: stop.0,
                        sections: TransitGrouper.sections(for: departures, now: Date())
                    )
                }
            }

            var byName: [String: TransitStopGroup] = [:]
            for try await stop in group {
                byName[stop.name] = stop
            }
            return stops.compactMap { byName[$0.0] }
        }
    }

    static let mock = TransitService {
        DashboardSnapshot.mockup.transitStops
    }
}

private func fetchDepartures(stationId: String, limit: Int) async throws -> [TransitDeparture] {
        var comps = URLComponents(string: "https://www.mvg.de/api/bgw-pt/v3/departures")!
        comps.queryItems = [
            URLQueryItem(name: "globalId",         value: stationId),
            URLQueryItem(name: "limit",             value: String(limit)),
            URLQueryItem(name: "offsetInMinutes",   value: "0"),
            URLQueryItem(name: "transportTypes",    value: "SBAHN")
        ]
        guard let url = comps.url else { throw TransitError.invalidURL }

        var request = URLRequest(url: url, timeoutInterval: 10)
        // MVG blocks requests without a browser-like User-Agent
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("https://www.mvg.de", forHTTPHeaderField: "Referer")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TransitError.serverError
        }

        return try TransitResponseParser.parse(data)
}

// MARK: - Errors

enum TransitError: LocalizedError {
    case invalidURL, serverError, parseError

    var errorDescription: String? {
        switch self {
        case .invalidURL:  return "Ungültige Abfahrts-URL"
        case .serverError: return "MVG-Server nicht erreichbar"
        case .parseError:  return "Abfahrtsdaten konnten nicht gelesen werden"
        }
    }
}

// MARK: - v3 Response parser
//
// Documented response shape (from MVG Observatory / bgw-pt v3):
// [
//   {
//     "plannedDepartureTime":  1718409600000,  // Unix ms
//     "realtimeDepartureTime": 1718409660000,  // Unix ms (absent when realtime=false)
//     "realtime": true,
//     "delayInMinutes": 0,
//     "transportType": "SBAHN",
//     "label": "S2",
//     "destination": "Ostbahnhof",
//     "cancelled": false,
//     "messages": [],
//     "occupancy": "LOW"
//   }, ...
// ]
// The response is a bare JSON array, not wrapped in an object.

enum TransitResponseParser {
    private struct Departure: Decodable {
        let plannedDepartureTime:  Int64
        let realtimeDepartureTime: Int64?
        let realtime:              Bool?
        let delayInMinutes:        Int?
        let label:                 String
        let destination:           String
        let cancelled:             Bool?
    }

    static func parse(_ data: Data) throws -> [TransitDeparture] {
        do {
            let deps = try JSONDecoder().decode([Departure].self, from: data)
            return deps.map { dep in
                let planned  = Date(timeIntervalSince1970: Double(dep.plannedDepartureTime) / 1000)
                let rt       = dep.realtimeDepartureTime ?? dep.plannedDepartureTime
                let realtime = Date(timeIntervalSince1970: Double(rt) / 1000)
                return TransitDeparture(
                    line:        dep.label,
                    destination: dep.destination,
                    planned:     planned,
                    realtime:    realtime,
                    cancelled:   dep.cancelled ?? false
                )
            }
        } catch {
            throw TransitError.parseError
        }
    }
}
